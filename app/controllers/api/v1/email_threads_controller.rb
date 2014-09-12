class Api::V1::EmailThreadsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:inbox, :in_folder, :remove_from_folder, :trash]

  swagger_controller :email_threads, 'Email Threads Controller'

  swagger_api :inbox do
    summary 'Return email threads in the inbox.'

    response :ok
  end

  def inbox
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first

    if inbox_label.nil?
      @email_threads = []
    else
      page = params[:page] ? params[:page].to_i : 1
      @email_threads = inbox_label.get_sorted_paginated_threads(page: page)
    end

    render 'api/v1/email_threads/index'
  end

  swagger_api :in_folder do
    summary 'Return email threads in folder.'

    param :query, :folder_id, :string, :required, 'Email Folder ID'

    response :ok
    response $config.http_errors[:email_folder_not_found][:status_code],
             $config.http_errors[:email_folder_not_found][:description]
  end

  def in_folder
    email_folder = GmailLabel.find_by(:gmail_account => current_user.gmail_accounts.first,
                                       :label_id => params[:folder_id])

    if email_folder.nil?
      render :status => $config.http_errors[:email_folder_not_found][:status_code],
             :json => $config.http_errors[:email_folder_not_found][:description]
      return
    end

    page = params[:page] ? params[:page].to_i : 1
    @email_threads = email_folder.get_sorted_paginated_threads(page: page)

    render 'api/v1/email_threads/index'
  end

  swagger_api :show do
    summary 'Return email thread.'

    param :path, :email_thread_uid, :string, :required, 'Email Thread UID'

    response :ok
    response $config.http_errors[:email_thread_not_found][:status_code],
             $config.http_errors[:email_thread_not_found][:description]
  end

  def show
  end

  swagger_api :remove_from_folder do
    summary 'Remove the specified email threads from the specified folder.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'

    response :ok
  end

  def remove_from_folder
    email_account = current_user.gmail_accounts.first
    email_thread_ids = EmailThread.where(:email_account => email_account, :uid => params[:email_thread_uids]).pluck(:id)
    email_ids = Email.where(:email_account => email_account, :email_thread_id => email_thread_ids).pluck(:id)
    email_folder = GmailLabel.find_by(:gmail_account => email_account, :label_id => params[:email_folder_id])
    
    EmailFolderMapping.where(:email => email_ids, :email_folder => email_folder).destroy_all if email_folder

    render :json => ''
  end

  swagger_api :trash do
    summary 'Move the specified email thread to the trash.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'

    response :ok
  end

  def trash
    email_account = current_user.gmail_accounts.first
    email_thread_ids = EmailThread.where(:email_account => email_account, :uid => params[:email_thread_uids]).pluck(:id)
    email_ids = Email.where(:email_account => email_account, :email_thread_id => email_thread_ids).pluck(:id)
    trash_label = GmailLabel.where(:gmail_account => email_account, :label_id => 'TRASH').first

    Email.trash_emails(email_ids, trash_label)

    render :json => ''
  end

  private

  # Before filters

  def correct_user
    @email_thread = EmailThread.find_by(:email_account => current_user.gmail_accounts.first,
                                        :uid => params[:email_thread_uid])

    if @email_thread.nil?
      render :status => $config.http_errors[:email_thread_not_found][:status_code],
             :json => $config.http_errors[:email_thread_not_found][:description]
      return
    end
  end
end

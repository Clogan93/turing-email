class Api::V1::EmailThreadsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:inbox, :in_folder, :move_to_folder, :apply_gmail_label,:remove_from_folder, :trash]
  before_action :correct_email_account
  before_action :filter_email_thread_uids, :only => [:move_to_folder, :apply_gmail_label, :remove_from_folder, :trash]

  swagger_controller :email_threads, 'Email Threads Controller'

  swagger_api :inbox do
    summary 'Return email threads in the inbox.'

    response :ok
  end

  def inbox
    inbox_label = @email_account.inbox_folder

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
    email_folder = GmailLabel.find_by(:gmail_account => @email_account,
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

  swagger_api :move_to_folder do
    summary 'Move the specified email threads to the specified folder.'
    notes 'If the folder name does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_name, :string, :required, 'Email Folder Name'

    response :ok
  end
  
  def move_to_folder
    emails = Email.where(:id => @email_ids)
    emails.each do |email|
      @email_account.move_email_to_folder(email, folder_name: params[:email_folder_name])
    end
    
    render :json => {}
  end

  swagger_api :apply_gmail_label do
    summary 'Apply the specified Gmail Label to the specified email threads.'
    notes 'If the Gmail Label does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :gmail_label_name, :string, :required, 'Gmail Label Name'

    response :ok
  end
  
  def apply_gmail_label
    emails = Email.where(:id => @email_ids)
    emails.each do |email|
      @email_account.apply_label_to_email(email, label_name: params[:gmail_label_name])
    end

    render :json => {}
  end

  swagger_api :remove_from_folder do
    summary 'Remove the specified email threads from the specified folder.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'

    response :ok
  end

  def remove_from_folder
    email_folder = GmailLabel.find_by(:gmail_account => @email_account, :label_id => params[:email_folder_id])
    EmailFolderMapping.where(:email => @email_ids, :email_folder => email_folder).destroy_all if email_folder

    render :json => {}
  end

  swagger_api :trash do
    summary 'Move the specified email thread to the trash.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'

    response :ok
  end

  def trash
    trash_folder = @email_account.trash_folder
    Email.trash_emails(@email_ids, trash_folder)

    render :json => {}
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

  def filter_email_thread_uids
    @email_thread_ids = EmailThread.where(:email_account => @email_account, :uid => params[:email_thread_uids]).pluck(:id)
    @email_ids = Email.where(:email_account => @email_account, :email_thread_id => @email_thread_ids).pluck(:id)
  end
end

class Api::V1::EmailThreadsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:inbox]

  swagger_controller :email_threads, 'Email Threads Controller'

  swagger_api :inbox do
    summary 'Return email threads in the inbox.'

    response :ok
  end

  def inbox
    inbox_label = GmailLabel.where(:gmail_account => current_user.gmail_accounts.first,
                                   :label_id => 'INBOX').first
    @email_threads = inbox_label.nil? ? [] : inbox_label.get_paginated_threads(params)

    render 'api/v1/email_threads/index'
  end

  swagger_api :in_folder do
    summary 'Return email threads in folder.'

    param :query, :folder_id, :string, :required, 'Email Folder ID'

    response :ok
    response $config.http_errors[:email_folder_not_found][:status_code], $config.http_errors[:email_folder_not_found][:description]
  end

  def in_folder
    email_thread_ids = @email_folder.emails.pluck(:email_thread_id)
    @email_threads = EmailThread.get_threads_from_ids(email_thread_ids)

    render 'api/v1/email_threads/index'
  end

  private

  # Before filters

  def correct_user
    @email_folder = GmailLabel.find_by(:gmail_account => current_user.gmail_accounts.first,
                                      :label_id => params[:folder_id])

    if @email_folder.nil?
      render :status => $config.http_errors[:email_folder_not_found][:status_code],
             :json => $config.http_errors[:email_folder_not_found][:description]
      return
    end
  end
end

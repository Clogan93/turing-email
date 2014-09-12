class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:set_seen, :remove_from_folder, :trash]

  swagger_controller :emails, 'Emails Controller'

  swagger_api :show do
    summary 'Return email.'

    param :path, :email_uid, :string, :required, 'Email UID'

    response :ok
    response $config.http_errors[:email_not_found][:status_code], $config.http_errors[:email_not_found][:description]
  end

  def show
  end

  swagger_api :set_seen do
    summary 'Update the seen status of the specified emails.'

    param :form, :email_uids, :string, :required, 'Email UIDs'
    param :form, :seen, :boolean, :required, 'Seen status'

    response :ok
  end
  
  def set_seen
    email_account = current_user.gmail_accounts.first
    Email.where(:email_account => email_account, :uid => params[:email_uids]).update_all(:seen => params[:seen])
    
    render :json => ''
  end

  swagger_api :remove_from_folder do
    summary 'Remove the specified emails from the specified folder.'

    param :form, :email_uids, :string, :required, 'Email UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'

    response :ok
  end

  def remove_from_folder
    email_account = current_user.gmail_accounts.first
    email_ids = Email.where(:email_account => email_account, :uid => params[:email_uids]).pluck(:id)
    email_folder = GmailLabel.find_by(:gmail_account => email_account, :label_id => params[:email_folder_id])
    
    EmailFolderMapping.where(:email => email_ids, :email_folder => email_folder).destroy_all if email_folder

    render :json => ''
  end

  swagger_api :trash do
    summary 'Move the specified emails to the trash.'

    param :form, :email_uids, :string, :required, 'Email UIDs'

    response :ok
  end

  def trash
    email_account = current_user.gmail_accounts.first
    email_ids = Email.where(:email_account => email_account, :uid => params[:email_uids]).pluck(:id)
    trash_label = GmailLabel.where(:gmail_account => email_account, :label_id => 'TRASH').first
    
    Email.trash_emails(email_ids, trash_label)
    
    render :json => ''
  end

  private

  # Before filters

  def correct_user
    @email = Email.find_by(:email_account => current_user.gmail_accounts.first,
                           :uid => params[:email_uid])

    if @email.nil?
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end
end

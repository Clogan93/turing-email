class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user, :except => [:set_seen, :move_to_folder, :apply_gmail_label, :remove_from_folder, :trash]
  before_action :correct_email_account, :except => [:show]
  before_action :filter_email_uids, :only => [:move_to_folder, :apply_gmail_label, :remove_from_folder, :trash]

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
    Email.where(:email_account => @email_account, :uid => params[:email_uids]).update_all(:seen => params[:seen])
    
    render :json => {}
  end

  swagger_api :move_to_folder do
    summary 'Move the specified emails to the specified folder.'
    notes 'If the folder name does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email UIDs'
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
    summary 'Apply the specified Gmail Label to the specified emails.'
    notes 'If the Gmail Label does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email UIDs'
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
    summary 'Remove the specified emails from the specified folder.'

    param :form, :email_uids, :string, :required, 'Email UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'

    response :ok
  end

  def remove_from_folder
    email_folder = GmailLabel.find_by(:gmail_account => @email_account, :label_id => params[:email_folder_id])
    
    EmailFolderMapping.where(:email => @email_ids, :email_folder => email_folder).destroy_all if email_folder

    render :json => {}
  end

  swagger_api :trash do
    summary 'Move the specified emails to the trash.'

    param :form, :email_uids, :string, :required, 'Email UIDs'

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
    @email = Email.find_by(:email_account => current_user.gmail_accounts.first,
                           :uid => params[:email_uid])

    if @email.nil?
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end

  def filter_email_uids
    @email_ids = Email.where(:email_account => @email_account, :uid => params[:email_uids]).pluck(:id)
  end
end

class Api::V1::EmailAccountsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_email_account

  swagger_controller :email_accounts, 'Email Accounts Controller'

  swagger_api :send_email do
    summary 'Send an email'

    param :form, :tos, :string, :required, 'Array of recipient email addresses'
    param :form, :subject, :string, :required, 'Subject'
    param :form, :email_body, :string, :required, 'Body'

    response :ok
  end

  def send_email
    @email_account.send_email(params[:tos], params[:subject], params[:email_body])
    render :json => {}
  end

  swagger_api :sync do
    summary 'Sync email. Returns true if any emails were synced, else false.'

    response :ok
  end
  
  def sync
    synced_emails = @email_account.sync_email()
    
    render :json => {:synced_emails => synced_emails}
  end
end
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
    render :json => ''
  end
end

class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user

  swagger_controller :emails, 'Emails Controller'

  swagger_api :show do
    summary 'Return email.'

    param :path, :email_account_type, :string, :required, 'Email Account Type'
    param :path, :email_account_id, :string, :required, 'Email Account ID'
    param :path, :email_uid, :string, :required, 'Email UID'

    response :ok
    response $config.http_errors[:email_not_found][:status_code], $config.http_errors[:email_not_found][:description]
  end

  def show
  end

  private

  # Before filters

  def correct_user
    @email = Email.find_by(:email_account_type => params[:email_account_type],
                           :email_account_id => params[:email_account_id],
                           :uid => params[:email_id])

    if @email.user != current_user
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end
end

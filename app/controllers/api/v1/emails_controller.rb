class Api::V1::EmailsController < ApiController
  before_action do
    signed_in_user(true)
  end

  before_action :correct_user

  swagger_controller :users, 'Emails Controller'

  swagger_api :show do
    summary 'Return email.'

    response :ok
  end

  def show
  end

  private

  # Before filters

  def correct_user
    @email = Email.find_by(:user => current_user,
                           :uid => params[:id])

    if @email.nil?
      render :status => $config.http_errors[:email_not_found][:status_code],
             :json => $config.http_errors[:email_not_found][:description]
      return
    end
  end
end

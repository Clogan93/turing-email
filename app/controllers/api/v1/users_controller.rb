class Api::V1::UsersController < ApiController
  before_action :except => :create do
    signed_in_user(true)
  end

  swagger_controller :users, 'Users Controller'

  swagger_api :create do
    summary 'Creates an account.'

    param :form, :email, :string, :required, 'Email'
    param :form, :password, :string, :required, 'Password (hashed)'

    response :ok
    response $config.http_errors[:already_have_account][:status_code], $config.http_errors[:already_have_account][:description]
    response $config.http_errors[:invalid_email_or_password][:status_code], $config.http_errors[:invalid_email_or_password][:description]
    response $config.http_errors[:email_in_use][:status_code], $config.http_errors[:email_in_use][:description]
  end

  def create
    if signed_in?
      render :status => $config.http_errors[:already_have_account][:status_code],
             :json => $config.http_errors[:already_have_account][:description]
      return
    end

    @user, success = User.api_create(params[:email], params[:password])

    if success
      sign_in @user
      
      render 'api/v1/users/show'
    else
      render :status => $config.http_errors[:invalid_email_or_password][:status_code],
             :json => $config.http_errors[:invalid_email_or_password][:description]
    end
  rescue ActiveRecord::RecordNotUnique => unique_violation
    if unique_violation.message =~ /index_users_on_email/
      render :status => $config.http_errors[:email_in_use][:status_code],
             :json => $config.http_errors[:email_in_use][:description]
    else
      raise unique_violation
    end
  rescue Exception => ex
    @user.destroy if @user

    raise ex
  end

  swagger_api :current do
    summary 'Return the current user.'

    response :ok
  end

  def current
    @user = current_user
    render 'api/v1/users/show'
  end
end

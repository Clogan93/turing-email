class Api::V1::SessionsController < ApiController
  swagger_controller :sessions, 'Session Management'

  swagger_api :create do
    summary 'Login'
    notes 'Logs the user in and sets a session cookie'
    
    param :form, :email, :string, :required, 'Email'
    param :form, :password, :string, :required, 'Password'
    
    response :unauthorized
    response $config.http_errors[:account_locked][:status_code], $config.http_errors[:account_locked][:description]
  end
  
  def create
    @user = User.find_by_email(params[:email])

    if @user
      if @user.login_attempt_count >= $config.max_login_attempts
        render :status => $config.http_errors[:account_locked][:status_code],
               :json => $config.http_errors[:account_locked][:description]
        return
      elsif @user.authenticate(params[:password])
        sign_in @user

        render 'api/v1/users/get_info'
        return
      else
        User.increment_counter(:login_attempt_count, @user.id)
      end
    end

    render :json => 'Invalid email/password combination',
           :status => 401
  end

  swagger_api :destroy do
    summary 'Logout'
  end
  
  def destroy
    sign_out
    render :json => ''
  end
end

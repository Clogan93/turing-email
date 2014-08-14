class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_email(params[:session][:email])

    if user
      if user.login_attempt_count >= $config.max_login_attempts
        flash[:danger] = 'Your account has been locked to protect your security. Please reset your password.'

        redirect_to forgot_password_url
        return
      elsif user.authenticate(params[:session][:password])
        sign_in user
        redirect_back_or root_path

        return
      else
        User.increment_counter(:login_attempt_count, user.id)
      end
    end

    flash.now[:danger] = 'Invalid email/password combination'
    render 'new'
  end

  def destroy
    sign_out
    redirect_to root_url
  end
end

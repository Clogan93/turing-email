module SessionsHelper
  def sign_in(user)
    auth_key = UserAuthKey.new_key
    encrypted_auth_key = UserAuthKey.encrypt(auth_key)

    user_auth_key = UserAuthKey.new()
    user_auth_key.user = user
    user_auth_key.encrypted_auth_key = encrypted_auth_key
    user_auth_key.save!

    cookies.permanent[:auth_key] = auth_key
    user.update_attribute(:login_attempt_count, 0)

    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    return if cookies[:auth_key].nil?
    return @current_user if @current_user

    encrypted_auth_key  = UserAuthKey.encrypt(cookies[:auth_key])
    user_auth_key = UserAuthKey.find_by_encrypted_auth_key(encrypted_auth_key)
    @current_user = user_auth_key.user if user_auth_key

    return @current_user
  end

  def current_user?(user)
    user == current_user
  end

  def signed_in_user(api = false)
    unless signed_in?
      if api
        render :json => 'Not signed in.', :status => 401
      else
        store_location
        redirect_to signin_url, flash: {:warning => 'Please sign in.'}
      end
    end
  end

  def sign_out
    auth_key = cookies[:auth_key]
    user_auth_key = UserAuthKey.find_by(:user => current_user,
                                        :encrypted_auth_key => UserAuthKey.encrypt(auth_key)) if auth_key
    user_auth_key.destroy() if user_auth_key

    cookies.delete(:auth_key)
    self.current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url if request.get?
  end
end

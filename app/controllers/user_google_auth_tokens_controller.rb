class UserGoogleAuthTokensController < ApplicationController
  before_action :signed_in_user

  def google_oauth2_callback
    error = params[:error]
    code = params[:code]

    if error || code.nil?
      if error == 'access_denied'
        flash[:danger] = "You did not grant #{$config.service_name_short} access to Gmail. Please try again."
      else
        flash[:danger] = $config.error_message_default.html_safe
      end

      redirect_to(root_url)
    else
      begin
        current_user.with_lock do
          current_user.user_google_auth_tokens.destroy_all

          oauth2_client = Google::OAuth2.get_client($config.google_client_id, $config.google_secret)
          oauth2_client.redirect_uri = google_oauth2_callback_url
          oauth2_client.code = code
          oauth2_client.fetch_access_token!()

          token = UserGoogleAuthToken.new
          token.user = current_user

          token.update(oauth2_client)

          token.save!
        end

        flash[:success] = 'Gmail authenticated!'
      rescue Exception => ex
        flash[:danger] = $config.error_message_default.html_safe
        log_email_exception(ex)
      end

      redirect_to(root_url)
    end
  end

  def google_oauth2_remove
    current_user.user_google_auth_tokens.destroy_all

    flash[:success] = 'Your Gmail account has been unlinked.'
    redirect_to(root_url)
  end
end

class GmailAccountsController < ApplicationController
  before_action :signed_in_user

  def oauth2_callback
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
      token = gmail_account = nil

      begin
        oauth2_client = Google::OAuth2.get_client($config.google_client_id, $config.google_secret)
        oauth2_client.redirect_uri = gmail_oauth2_callback_url
        oauth2_client.code = code
        oauth2_client.fetch_access_token!()

        current_user.with_lock do
          current_user.gmail_accounts.destroy_all

          # don't save because no GmailAccount yet to set to required google_api attribute.
          google_oauth2_token = GoogleOAuth2Token.new()
          google_oauth2_token.update(oauth2_client, false)

          # don't assign google_o_auth2_token yet because it hasn't been saved so no ID.
          gmail_account = GmailAccount.new()
          gmail_account.user = current_user
          gmail_account.refresh_user_info(google_oauth2_token.api_client())

          google_oauth2_token.google_api = gmail_account
          google_oauth2_token.save!

          gmail_account.google_o_auth2_token = google_oauth2_token
          gmail_account.save!
        end

        flash[:success] = 'Gmail authenticated!'
      rescue Exception => ex
        log_exception(false) { gmail_account.destroy! if gmail_account }
        log_exception(false) { token.destroy! if token }

        flash[:danger] = $config.error_message_default.html_safe
        log_email_exception(ex)
      end

      redirect_to(root_url)
    end
  end

  def oauth2_remove
    current_user.gmail_accounts.destroy_all

    flash[:success] = 'Your Gmail account has been unlinked.'
    redirect_to(root_url)
  end
end

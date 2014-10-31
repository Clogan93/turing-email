class GmailAccountsController < ApplicationController
  def o_auth2_callback
    error = params[:error]
    code = params[:code]

    if error || code.nil?
      if error == 'access_denied'
        flash[:danger] = I18n.t('gmail.access_not_granted')
      else
        flash[:danger] = I18n.t(:error_message_default).html_safe
      end

      redirect_to(root_url)
    else
      token = nil
      gmail_account = nil
      created_gmail_account = false

      begin
        o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)
        o_auth2_base_client.redirect_uri = gmail_oauth2_callback_url
        o_auth2_base_client.code = code
        o_auth2_base_client.fetch_access_token!()

        # don't save because no GmailAccount yet to set to required google_api attribute.
        google_o_auth2_token = GoogleOAuth2Token.new()
        google_o_auth2_token.update(o_auth2_base_client, false)
        api_client = google_o_auth2_token.api_client()
        
        if current_user.nil?
          userinfo_data = GmailAccount.get_userinfo(api_client)

          gmail_account = GmailAccount.find_by_google_id(userinfo_data['id'])
          
          if gmail_account
            user = gmail_account.user
          else
            user = User.new()
            user.email = userinfo_data['email'].downcase
            user.password = user.password_confirmation = SecureRandom.uuid()
            user.save!
          end
          
          sign_in(user)
        else
          user = current_user
        end
        
        user.with_lock do
          gmail_account = user.gmail_accounts.first
          if gmail_account
            gmail_account.delete_o_auth2_token()
            gmail_account.last_history_id_synced = nil
            gmail_account.save!
          end

          # don't assign google_o_auth2_token yet because it hasn't been saved so no ID.
          if gmail_account.nil?
            created_gmail_account = true

            gmail_account = GmailAccount.new()
            gmail_account.user = user
          end
          gmail_account.refresh_user_info(api_client)

          google_o_auth2_token.google_api = gmail_account
          google_o_auth2_token.save!

          gmail_account.google_o_auth2_token = google_o_auth2_token
          gmail_account.save!
        end

        flash[:success] = I18n.t('gmail.authenticated')
      rescue Exception => ex
        log_exception(false) { gmail_account.destroy! if created_gmail_account && gmail_account }
        log_exception(false) { token.destroy! if token }

        flash[:danger] = I18n.t(:error_message_default).html_safe
        log_email_exception(ex)
      end

      redirect_to(root_url)
    end
  end

  def o_auth2_remove
    current_user.with_lock do
      gmail_account = current_user.gmail_accounts.first
      if gmail_account
        gmail_account.delete_o_auth2_token()
        gmail_account.last_history_id_synced = nil
        gmail_account.save!
      end
    end

    flash[:success] = flash[:success] = I18n.t('gmail.unlinked')
    redirect_to(root_url)
  end
end

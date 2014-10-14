module GmailAccountsHelper
  def gmail_o_auth2_url(force = false)
    o_auth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)

    o_auth2_base_client.redirect_uri = gmail_oauth2_callback_url
    o_auth2_base_client.scope = %w(https://www.googleapis.com/auth/userinfo.email
                                  https://www.googleapis.com/auth/gmail.readonly
                                  https://www.googleapis.com/auth/gmail.compose
                                  https://www.googleapis.com/auth/gmail.modify)

    options = {}
    options[:access_type] = :offline
    options[:approval_prompt] = force ? :force : :auto
    options[:include_granted_scopes] = true

    url = o_auth2_base_client.authorization_uri(options).to_s()
    return url
  end
end

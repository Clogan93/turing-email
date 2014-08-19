module GmailAccountsHelper
  def gmail_oauth2_url(force = false)
    oauth2_base_client = Google::OAuth2Client.base_client($config.google_client_id, $config.google_secret)

    oauth2_base_client.redirect_uri = gmail_oauth2_callback_url
    oauth2_base_client.scope = %w(https://www.googleapis.com/auth/userinfo.email
                                  https://www.googleapis.com/auth/gmail.readonly)

    options = {}
    options[:access_type] = :offline
    options[:approval_prompt] = force ? :force : :auto
    options[:include_granted_scopes] = true

    url = oauth2_base_client.authorization_uri(options).to_s()
    return url
  end
end

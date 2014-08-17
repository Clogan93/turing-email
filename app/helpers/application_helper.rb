module ApplicationHelper
  def google_oauth2_url(force = false)
    oauth2_client = Google::OAuth2.get_client($config.google_client_id, $config.google_secret)

    oauth2_client.redirect_uri = google_oauth2_callback_url
    oauth2_client.scope = %w(https://www.googleapis.com/auth/userinfo.email
                             https://www.googleapis.com/auth/gmail.modify
                             https://www.googleapis.com/auth/gmail.readonly
                             https://www.googleapis.com/auth/gmail.compose)

    options = {}
    options[:access_type] = :offline
    options[:approval_prompt] = force ? :force : :auto
    options[:include_granted_scopes] = true

    url = oauth2_client.authorization_uri(options).to_s()
    return url
  end
end

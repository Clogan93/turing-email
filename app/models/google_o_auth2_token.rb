class GoogleOAuth2Token < ActiveRecord::Base
  belongs_to :google_api, polymorphic: true

  validates_presence_of(:google_api_id, :google_api_type)
  validates_presence_of(:access_token, :expires_in, :issued_at, :refresh_token)
  validates_presence_of(:expires_at)

  before_destroy {
    log_exception(false) { RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{self.refresh_token}") }
    log_exception(false) { RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{self.access_token}") }
  }

  def oauth2_client()
    log_console('get oauth2_client')
    self.log()

    oauth2_client = Google::OAuth2.get_client($config.google_client_id, $config.google_secret)

    oauth2_client.access_token = self.access_token
    oauth2_client.expires_in = self.expires_in
    oauth2_client.issued_at = Time.at(self.issued_at)
    oauth2_client.refresh_token = self.refresh_token

    self.refresh(oauth2_client)

    return oauth2_client
  end

  def api_client()
    oauth2_client = self.oauth2_client()

    api_client = Google::APIClient.new(:application_name => $config.service_name)
    api_client.authorization = oauth2_client

    return api_client
  end

  def refresh(oauth2_client)
    # guard against simultaneous refreshes

    self.with_lock do
      #if oauth2_client.expired?
      return if self.expires_at - Time.now >= 60.seconds

      log_console('REFRESHING TOKEN')
      self.log()

      oauth2_client.fetch_access_token!()
      self.update(oauth2_client)

      log_console('TOKEN REFRESHED!')
      self.log()
    end
  end

  def update(oauth2_client, do_save = true)
    log_console('UPDATING TOKEN')
    self.log()

    self.access_token = oauth2_client.access_token
    self.expires_in = oauth2_client.expires_in
    self.issued_at = oauth2_client.issued_at
    self.refresh_token = oauth2_client.refresh_token

    self.expires_at = Time.now + self.expires_in.seconds

    self.save! if do_save

    log_console('TOKEN UPDATED')
    self.log()
  end

  def log()
    log_console("access_token=#{self.access_token}\n" +
                "expires_in=#{self.expires_in}\n" +
                "issued_at=#{self.issued_at}\n" +
                "refresh_token=#{self.refresh_token}\n")
  end
end

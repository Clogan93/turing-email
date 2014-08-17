require 'rest-client'
require 'google/api_client'

class UserGoogleAuthToken < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :presence => true

  validates :access_token, :presence => true
  validates :expires_in, :presence => true
  validates :issued_at, :presence => true
  validates :refresh_token, :presence => true

  validates :expires_at, :presence => true

  validates :google_id, :presence => true
  validates :email, :presence => true
  validates :verified_email, :presence => true

  before_destroy {
    log_exception(false) { RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{self.refresh_token}") }
    log_exception(false) { RestClient.get("https://accounts.google.com/o/oauth2/revoke?token=#{self.access_token}") }
  }

  def oauth2_client()
    log_console("get oauth2_client")
    self.log()

    self.with_lock do
      oauth2_client = Google::OAuth2.get_client($config.google_client_id, $config.google_secret)

      oauth2_client.access_token = self.access_token
      oauth2_client.expires_in = self.expires_in
      oauth2_client.issued_at = Time.at(self.issued_at)
      oauth2_client.refresh_token = self.refresh_token

      #if oauth2_client.expired?
      if self.expires_at - Time.now < 60.seconds
        self.refresh(oauth2_client)
      end

      return oauth2_client
    end
  end

  def api_client()
    oauth2_client = self.oauth2_client()

    api_client = Google::APIClient.new(:application_name => $config.service_name)
    api_client.authorization = oauth2_client

    return api_client
  end

  def refresh(oauth2_client)
    log_console('REFRESHING TOKEN')
    self.log()

    self.with_lock do
      oauth2_client.fetch_access_token!()
      self.update(oauth2_client)
    end

    log_console('TOKEN REFRESHED!')
    self.log()
  end

  def update(oauth2_client)
    log_console('UPDATING TOKEN')
    self.log()

    self.with_lock do
      self.access_token = oauth2_client.access_token
      self.expires_in = oauth2_client.expires_in
      self.issued_at = oauth2_client.issued_at
      self.refresh_token = oauth2_client.refresh_token

      self.expires_at = Time.now + self.expires_in.seconds

      oauth2 = Google::OAuth2.new(self.api_client())
      json = oauth2.userinfo_get()

      self.google_id = json['id']
      self.email = json['email'].downcase
      self.verified_email = json['verified_email']

      self.save!
    end

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

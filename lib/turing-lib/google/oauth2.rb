require 'signet/oauth_2/client'

module Google
  class OAuth2
    def OAuth2.get_client(client_id, client_secret)
      oauth2_client = Signet::OAuth2::Client.new()

      oauth2_client.client_id = client_id
      oauth2_client.client_secret = client_secret

      oauth2_client.authorization_uri = 'https://accounts.google.com/o/oauth2/auth'
      oauth2_client.token_credential_uri = 'https://accounts.google.com/o/oauth2/token'

      return oauth2_client
    end

    attr_accessor :api_client, :oauth2_api

    def initialize(api_client)
      self.api_client = api_client
      self.oauth2_api = api_client.discovered_api('oauth2', 'v2')
    end

    def userinfo_get()
      result = self.api_client.execute(:api_method => self.oauth2_api.userinfo.get)
      return JSON.parse(result.data.to_json())
    end
  end
end

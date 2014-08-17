class GmailAccount < ActiveRecord::Base
  belongs_to :user

  has_one :google_o_auth2_token,
          :as => :google_api,
          :dependent => :destroy

  validates_presence_of(:user_id, :google_id, :email, :verified_email)

  def refresh_user_info(api_client = nil, do_save = true)
    api_client = self.google_o_auth2_token.api_client() if api_client.nil?
    oauth2 = Google::OAuth2.new(api_client)
    json = oauth2.userinfo_get()

    self.google_id = json['id']
    self.email = json['email'].downcase
    self.verified_email = json['verified_email']

    self.save! if do_save
  end
end

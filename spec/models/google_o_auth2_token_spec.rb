require 'rails_helper'

describe GoogleOAuth2Token, :type => :model do
  let(:gmail_account) { FactoryGirl.create(:gmail_account) }
  
  context 'validations' do
    it 'should fail to save without certain attributes set' do
      google_o_auth2_token = GoogleOAuth2Token.new
      expect(google_o_auth2_token.save).to be(false)

      google_o_auth2_token.google_api = gmail_account
      expect(google_o_auth2_token.save).to be(false)

      google_o_auth2_token.access_token = 'access token'
      expect(google_o_auth2_token.save).to be(false)
      google_o_auth2_token.expires_in = '360'
      expect(google_o_auth2_token.save).to be(false)
      google_o_auth2_token.issued_at = DateTime.now
      expect(google_o_auth2_token.save).to be(false)
      google_o_auth2_token.refresh_token = 'refresh token'
      expect(google_o_auth2_token.save).to be(false)
      google_o_auth2_token.expires_at = DateTime.now
      expect(google_o_auth2_token.save).to be(true)
    end
  end
end
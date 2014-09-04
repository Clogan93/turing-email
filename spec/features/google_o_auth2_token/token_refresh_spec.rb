require 'rails_helper'

describe 'Google OAuth 2 token refreshing', :type => :feature, :js => true do
  let!(:user) {  FactoryGirl.create(:user) }
  before {
    capybara_signin_user(user)
    capybara_link_gmail(user)
  }
  
  it 'should not refresh the token when it has not expired' do
    google_o_auth2_token = user.gmail_accounts.first.google_o_auth2_token
    
    access_token = google_o_auth2_token.access_token
    expires_in = google_o_auth2_token.expires_in
    issued_at = google_o_auth2_token.issued_at
    refresh_token = google_o_auth2_token.refresh_token
    expires_at = google_o_auth2_token.expires_at

    o_auth2_base_client = google_o_auth2_token.o_auth2_base_client()
    google_o_auth2_token.refresh(o_auth2_base_client)
    
    expect(google_o_auth2_token.access_token).to eq(access_token)
    expect(google_o_auth2_token.expires_in).to eq(expires_in)
    expect(google_o_auth2_token.issued_at).to eq(issued_at)
    expect(google_o_auth2_token.refresh_token).to eq(refresh_token)
    expect(google_o_auth2_token.expires_at).to eq(expires_at)
  end

  it 'should refresh the token when forced' do
    google_o_auth2_token = user.gmail_accounts.first.google_o_auth2_token
    o_auth2_base_client = google_o_auth2_token.o_auth2_base_client()
    
    issued_at = google_o_auth2_token.issued_at
    expires_at = google_o_auth2_token.expires_at
    
    google_o_auth2_token.refresh(o_auth2_base_client, true)

    expect(google_o_auth2_token.issued_at).not_to eq(issued_at)
    expect(google_o_auth2_token.expires_at).not_to eq(expires_at)
  end
end
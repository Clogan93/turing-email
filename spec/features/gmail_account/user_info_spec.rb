require 'rails_helper'

describe 'Gmail user info support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }

  it 'should refresh the user info' do
    gmail_account = user.gmail_accounts.first

    google_id = gmail_account.google_id
    email = gmail_account.email
    verified_email = gmail_account.verified_email
    gmail_account.google_id = gmail_account.email = gmail_account.verified_email = nil
    
    gmail_account.refresh_user_info()
    
    expect(gmail_account.google_id).to eq(google_id)
    expect(gmail_account.email).to eq(email)
    expect(gmail_account.verified_email).to eq(verified_email)
  end
end

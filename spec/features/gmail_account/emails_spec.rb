require 'rails_helper'

describe 'Gmail emails support', :type => :feature, :js => true, :link_gmail_account => true do
  let!(:user) {  FactoryGirl.create(:user) }
  
  it 'sync the emails' do
    gmail_account = user.gmail_accounts.first
    #gmail_account.sync_email()
  end
end

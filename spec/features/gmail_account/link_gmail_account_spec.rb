require 'rails_helper'

describe 'link gmail account', :type => :feature do
  let(:user) { FactoryGirl.create(:user) }
  before { capybara_signin_user(user) }

  it 'link the gmail account' do
    visit '/'
    
    
  end
end

require 'rails_helper'

describe 'authenticating Gmail', :type => :feature, :js => true do
  let!(:user) {  FactoryGirl.create(:user) }
  before { capybara_signin_user(user) }
  
  it 'links, changes, and unlinks the gmail account' do
    visit '/'
    click_link 'Link Gmail Account'

    fill_in('Email', :with => SpecMisc::GMAIL_TEST_EMAIL)
    fill_in('Password', :with => SpecMisc::GMAIL_TEST_PASSWORD)
    click_button('Sign in')

    click_button('Cancel')
    expect(page).to have_content(I18n.t('gmail.access_not_granted'))

    click_link 'Link Gmail Account'
    sleep(2)
    click_button('Accept')
    expect(page).to have_content(I18n.t('gmail.authenticated'))

    expect(user.gmail_accounts.count).to eq(1)
    expect(user.gmail_accounts.first.google_o_auth2_token).not_to be(nil)
    
    click_link 'Unlink Gmail Account'
    expect(page).to have_content(I18n.t('gmail.unlinked'))

    expect(user.gmail_accounts.count).to eq(1)
    expect(user.gmail_accounts.first.google_o_auth2_token).to be(nil)
  end
end

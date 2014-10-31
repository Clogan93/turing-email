require 'rails_helper'

describe 'authenticating Gmail', :type => :feature, :js => true do
  let!(:user) {  FactoryGirl.create(:user) }
  before { capybara_signin_user(user) }
  
  it 'should authenticate, change, and unlink the Gmail account' do
    visit gmail_o_auth2_url(true)

    if has_field?('Email')
      fill_in('Email', :with => SpecMisc::GMAIL_TEST_EMAIL)
      fill_in('Password', :with => SpecMisc::GMAIL_TEST_PASSWORD)
      click_button('Sign in')
    end

    sleep(2)
    click_button('Cancel')
    expect(page).to have_content(I18n.t('gmail.access_not_granted'))

    visit gmail_o_auth2_url(true)
    sleep(2)
    click_button('Accept')
    expect(page).to have_content(I18n.t('gmail.authenticated'))

    expect(user.gmail_accounts.count).to eq(1)
    expect(user.gmail_accounts.first.google_o_auth2_token).not_to be(nil)

    expect(user.destroy).not_to be(false)
  end
end

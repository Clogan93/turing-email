require 'rails_helper'

describe 'the home page', :type => :feature do
  context 'when the user is not signed in' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should have the correct links' do
      visit '/'

      expect(page).to have_link('Login')
      expect(page).to have_link('Register')

      expect(page).to_not have_link('Signout')
      expect(page).to_not have_link('Mail')
    end
  end

  context 'when the user is signed in' do
    let(:user) { FactoryGirl.create(:user) }
    before { capybara_signin_user(user) }

    it 'should have the correct links' do
      visit '/'

      expect(page).to have_link('Signout')
      expect(page).to have_link('Mail')

      expect(page).to_not have_link('Login')
      expect(page).to_not have_link('Register')
    end
  end
end

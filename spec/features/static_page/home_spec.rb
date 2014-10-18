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
      expect(page).to_not have_link('Link Gmail Account')
      expect(page).to_not have_link('Change Gmail Account')
      expect(page).to_not have_link('Unlink Gmail Account')
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

    context 'when the user does NOT have a Gmail account linked' do
      it 'should have the correct Gmail links' do
        visit '/'

        expect(page).to have_link('Link Gmail Account')
        expect(page).to_not have_link('Change Gmail Account')
        expect(page).to_not have_link('Unlink Gmail Account')
      end
    end

    context 'when the user has a Gmail account linked' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, :user => user) }

      it 'should have the correct Gmail links' do
        visit '/'

        expect(page).to_not have_link('Link Gmail Account')
        expect(page).to have_link('Change Gmail Account')
        expect(page).to have_link('Unlink Gmail Account')
      end
    end
  end
end

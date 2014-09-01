require 'rails_helper'

describe 'the home page', :type => :feature do
  context 'when the user is not signed in' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should have the correct links' do
      visit '/'

      expect(page).to have_link('Signin')
      expect(page).to have_link('Signup')

      expect(page).to_not have_link('Signout')
      expect(page).to_not have_link('Mail')

      expect(page).to_not have_link('Link Gmail Account')
      expect(page).to_not have_link('Change Gmail Account')
      expect(page).to_not have_link('Unlink Gmail Account')
    end

    it 'should signin the user' do
      capybara_signin_user(user)
    end
  end

  context 'when the user is signed in' do
    let(:user) { FactoryGirl.create(:user) }
    before { capybara_signin_user(user) }

    it 'should have the correct links' do
      visit '/'

      expect(page).to have_link('Signout')
      expect(page).to have_link('Mail')

      expect(page).to have_link('Link Gmail Account')
      expect(page).to_not have_link('Change Gmail Account')
      expect(page).to_not have_link('Unlink Gmail Account')

      expect(page).to_not have_link('Signin')
      expect(page).to_not have_link('Signup')
    end

    context 'when the user has a Gmail account linked' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, :user => user) }

      it 'should have the correct links' do
        visit '/'

        expect(page).to_not have_link('Link Gmail Account')
        expect(page).to have_link('Change Gmail Account')
        expect(page).to have_link('Unlink Gmail Account')
      end
    end
  end
end

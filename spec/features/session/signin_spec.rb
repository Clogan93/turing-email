require 'rails_helper'

describe 'the signin page', :type => :feature do
  let(:user) { FactoryGirl.create(:user) }

  it 'should have the correct links and fields' do
    visit '/signin'

    find_field('Email')
    find_field('Password')
    expect(page).to have_button('Login')

    expect(page).to have_link('Signup now!')
  end

  context 'when the email and passowrd are correct' do
    it 'should signin the user' do
      capybara_signin_user(user)
    end
  end

  context 'when the email or password is incorrect' do
    before { visit '/signin' }

    context 'when the email is incorrect' do
      it 'should NOT signin the user and show the correct error message' do
        fill_in('Email', :with => 'invalid_email')
        fill_in('Password', :with => user.password)
        click_button('Login')

        expect(page).to have_content('Invalid email/password combination')
      end
    end

    context 'when the password is incorrect' do
      it 'should NOT signin the user and show the correct error message' do
        fill_in('Email', :with => user.email)
        fill_in('Password', :with => 'invalid_password')
        click_button('Login')

        expect(page).to have_content('Invalid email/password combination')
      end
    end
  end

  context 'when the account is locked' do
    let(:locked_user) { FactoryGirl.create(:locked_user) }
    before { visit '/signin' }

    it 'should NOT signin the user and show the correct error message' do
      fill_in('Email', :with => locked_user.email)
      fill_in('Password', :with => locked_user.password)
      click_button('Login')

      expect(page).to have_title('Reset Password')
    end
  end
end

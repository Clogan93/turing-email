require 'rails_helper'

describe 'the signup page', :type => :feature do
  it 'should have the correct links and fields' do
    visit '/signup'

    find_field('Email')
    find_field('Password')
    find_field('Confirm Password')
    expect(page).to have_button('Register')
  end

  context 'when the email is invalid' do
    it 'should show the correct error message' do
      visit '/signup'

      fill_in('Email', :with => 'invalid_email')
      click_button('Register')

      expect(page).to have_content('Email is invalid')
    end
  end

  context 'when the password and confirmation do not match' do
    it 'should show the correct error message' do
      visit '/signup'

      fill_in('Password', :with => 'Password')
      fill_in('Confirm Password', :with => 'Password2')
      click_button('Register')

      expect(page).to have_content('Password confirmation doesn\'t match Password')
    end
  end

  context 'when the email is in use' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should create the account' do
      visit '/signup'

      fill_in('Email', :with => user.email)
      fill_in('Password', :with => user.password)
      fill_in('Confirm Password', :with => user.password)
      click_button('Register')

      expect(page).to have_content('Error email in use')
    end
  end

  context 'when the email, password, and confirmation password are valid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should create the account' do
      visit '/signup'

      fill_in('Email', :with => user.email)
      fill_in('Password', :with => user.password)
      fill_in('Confirm Password', :with => user.password)
      click_button('Register')

      expect(page).to have_content('Welcome to Turing!')
    end
  end
end
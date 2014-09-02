require 'rails_helper'

describe User, :type => :model do
  let(:user_template) { FactoryGirl.build(:user) }

  context 'get_unique_violation_error' do
    it 'should return the email error message when the email is in use' do
      begin
        expect(user_template.save).to be(true)

        user = User.new()
        user.email = user_template.email
        user.password = user.password_confirmation = user_template.password
        expect(user.save).to be(true)

        assert false
      rescue ActiveRecord::RecordNotUnique => unique_violation
        expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
      end
    end
  end

  context 'when using create_from_post' do
    let(:params) {  ActionController::Parameters.new(
                      :user => { :email => user_template.email,
                                 :password => user_template.password,
                                 :confirm_password => user_template.password}
                      ) }

    it 'should create a user when the email and password are valid' do
      user, result = User.create_from_post(params)
      expect(result).to eq(true)
      expect(User.find_by_email(user_template.email).id).to eq(user.id)
    end

    it 'should NOT create a user when the email is invalid' do
      params[:user][:email] = 'invalid email'
      user, result = User.create_from_post(params)
      expect(result).to eq(false)
      expect(User.find_by_email(user_template.email)).to be(nil)
    end

    it 'should NOT create a user when the email is in use' do
      begin
        expect(user_template.save).to be(true)
        user, result = User.create_from_post(params)
        assert false
      rescue ActiveRecord::RecordNotUnique => unique_violation
        expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
      end
    end
  end

  context 'when using api_create' do
    it 'should create a user when the email and password are valid' do
      user, result = User.api_create(user_template.email, user_template.password)
      expect(result).to eq(true)
      expect(User.find_by_email(user_template.email).id).to eq(user.id)
    end

    it 'should NOT create a user when the email is invalid' do
      user, result = User.api_create('invalid email', user_template.password)
      expect(result).to eq(false)
      expect(User.find_by_email(user_template.email)).to be(nil)
    end

    it 'should NOT create a user when the email is in use' do
      begin
        expect(user_template.save).to be(true)
        user, result = User.api_create(user_template.email, user_template.password)
        assert false
      rescue ActiveRecord::RecordNotUnique => unique_violation
        expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
      end
    end
  end
end
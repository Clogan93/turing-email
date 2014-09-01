require 'rails_helper'

describe Api::V1::UsersController, :type => :controller do
  context 'when the email is already in use' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should not create the account' do
      post :create, :email => user.email, :password => user.password

      expect(response).to have_http_status($config.http_errors[:email_in_use][:status_code])
    end
  end

  context 'when the email is invalid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should not create the account' do
      post :create, :email => 'invalid_email', :password => user.password

      expect(response).to have_http_status($config.http_errors[:invalid_email_or_password][:status_code])
    end
  end

  context 'when the email and password are valid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should create the account' do
      post :create, :email => user.email, :password => user.password

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/users/show')
    end
  end
end

require 'rails_helper'

describe 'Users management' do
  describe 'Users' do
    context 'when the email is already in use' do
      let(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/users', :email => user.email, :password => user.password }

      it 'should not create the account' do
        expect(response).to have_http_status($config.http_errors[:email_in_use][:status_code])
      end
    end

    context 'when the email is invalid' do
      before { post '/api/v1/users', :email => 'email', :password => 'Password1' }

      it 'should not create the account' do
        expect(response).to have_http_status($config.http_errors[:invalid_email_or_password][:status_code])
      end
    end

    context 'when the email and password are valid' do
      before { post '/api/v1/users', :email => 'test@test.com', :password => 'Password1' }

      it 'should create the account' do
        expect(response).to have_http_status(:ok)
        user = JSON.parse(response.body)['user']

        expect(user['email']).to eq('test@test.com')
      end
    end

    context 'when an account exists' do
      before do
        @user = FactoryGirl.create(:user)

        post '/api/v1/sessions', :email => @user.email, :password => @user.password
        expect(response).to have_http_status(:ok)
      end
    end
  end
end

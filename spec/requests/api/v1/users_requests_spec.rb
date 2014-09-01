require 'rails_helper'

describe Api::V1::UsersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user_other) { FactoryGirl.create(:user) }

  context 'when the user is signed in' do
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }

    it 'should not create an account' do
      post '/api/v1/users', :email => user.email, :password => user.password

      expect(response).to have_http_status($config.http_errors[:already_have_account][:status_code])
    end

    it 'should return the user info' do
      get '/api/v1/users/current'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/users/show')

      user_rendered = JSON.parse(response.body)
      expect(user_rendered['email']).to eq(user.email)
      expect(user_rendered['email']).not_to eq(user_other.email)
    end
  end

  context 'when the other user is signed in' do
    before { post '/api/v1/sessions', :email => user_other.email, :password => user_other.password }

    it 'should return the other user info' do
      get '/api/v1/users/current'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/users/show')

      user_rendered = JSON.parse(response.body)
      expect(user_rendered['email']).to eq(user_other.email)
      expect(user_rendered['email']).not_to eq(user.email)
    end
  end

  context 'when the user is NOT signed in' do
    it 'should NOT return the current user info' do
      get '/api/v1/users/current'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end

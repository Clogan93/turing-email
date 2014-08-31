require 'rails_helper'

describe Api::V1::UsersController, :type => :request do
  context 'when the user is logged in' do
    let(:user) { FactoryGirl.create(:user) }
    before { post '/api/v1/sessions', :email => user.email, :password => user.password }

    it 'should return the current user info' do
      get '/api/v1/users/current'

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/users/show')

      user_rendered = JSON.parse(response.body)
      expect(user_rendered['email']).to eq(user.email)
    end
  end

  context 'when the user is NOT logged in' do
    it 'should NOT return the current user info' do
      get '/api/v1/users/current'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end

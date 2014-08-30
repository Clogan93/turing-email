require 'rails_helper'

describe Api::V1::SessionsController, :type => :controller do
  context 'when the username and password is invalid' do
    it 'should not login the user' do
      post :create, post: {:email => 'test@blah.com', :password => 'asfasdf'}

      expect(response).to have_http_status(:unauthorized)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when the account is locked' do
    let(:user) { FactoryGirl.create(:locked_user) }

    it 'should not login the user' do
      post :create, :email => user.email, :password => user.password

      expect(response).to have_http_status($config.http_errors[:account_locked][:status_code])
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when the username and password is valid' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should login the user' do
      post :create, :email => user.email, :password => user.password

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to_not eq(nil)
    end
  end

  context 'when the user is logged in' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      post :create, :email => user.email, :password => user.password
    end

    it 'should logout the user' do
      delete :destroy

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when there user is not logged in' do
    it 'logout should still succeed' do
      delete :destroy

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end
end

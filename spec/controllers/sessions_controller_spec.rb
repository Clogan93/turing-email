require 'rails_helper'

RSpec.describe Api::V1::SessionsController, :type => :controller do
  describe 'Sessions' do
    context 'when the username and password is invalid' do
      before { post :create, post: {:email => 'test@blah.com', :password => 'asfasdf'} }

      it 'should not login the user' do
        expect(response).to have_http_status(:unauthorized)
        expect(response.cookies['auth_key']).to eq(nil)
      end
    end

    context 'when the account is locked' do
      let(:user) { FactoryGirl.create(:locked_user) }
      before { post :create, :email => user.email, :password => user.password }

      it 'should not login the user' do
        expect(response).to have_http_status($config.http_errors[:account_locked][:status_code])
        expect(response.cookies['auth_key']).to eq(nil)
      end
    end

    context 'when the username and password is valid' do
      let(:user) { FactoryGirl.create(:user) }
      before { post :create, :email => user.email, :password => user.password }

      it 'should login the user' do
        expect(response).to have_http_status(:ok)
        expect(response.cookies['auth_key']).to_not eq(nil)
      end
    end

    context 'when the user is logged in' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        post :create, :email => user.email, :password => user.password
        delete :destroy
      end

      it 'should logout the user' do
        expect(response).to have_http_status(:ok)
        expect(response.cookies['auth_key']).to eq(nil)
      end
    end

    context 'when there user is not logged in' do
      before do
        delete :destroy
      end

      it 'should logout should succeed' do
        expect(response).to have_http_status(:ok)
        expect(response.cookies['auth_key']).to eq(nil)
      end
    end
  end
end

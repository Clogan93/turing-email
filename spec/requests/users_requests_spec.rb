require 'rails_helper'

describe UsersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:user_other) { FactoryGirl.create(:user) }

  context 'when the user is signed in' do
    before { post '/sessions', :session => { :email => user.email, :password => user.password } }

    it 'should not render the signup page' do
      get signup_path

      expect(response).to redirect_to(root_url)
      expect(request.flash[:info]).to match(/already have an account/)
    end

    it 'should not create an account' do
      post '/users', :user => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(root_url)
      expect(request.flash[:info]).to match(/already have an account/)
    end
  end
end
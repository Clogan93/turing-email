require 'rails_helper'

describe UsersController, :type => :request do
  context 'when the user is not signed in' do
    it 'should render new' do
      get signup_path

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(request.flash[:info]).to be_nil
    end
  end

  context 'when the email is already in use' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should not create the account' do
      post users_path, :user => { :email => user.email, :password => user.password }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(request.flash[:danger]).to match(/email in use/)
    end
  end

  context 'when the email is invalid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should not create the account' do
      post users_path, :user => { :email => 'invalid_email', :password => user.password }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(response.body).to match(/Email is invalid/)
    end
  end

  context 'when the email and password are valid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should create the account' do
      post users_path, :user => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(root_url)
    end
  end

  context 'when the user is signed in' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    
    before { post '/sessions', :session => { :email => user.email, :password => user.password } }

    it 'should not render the signup page' do
      get signup_path

      expect(response).to redirect_to(root_url)
      expect(request.flash[:info]).to match(/already have an account/)
    end

    it 'should not create an account' do
      post users_path, :user => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(root_url)
      expect(request.flash[:info]).to match(/already have an account/)
    end
  end
end
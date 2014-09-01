require 'rails_helper'

describe UsersController, :type => :controller do
  context 'when the user is not signed in' do
    it 'should render new' do
      get :new

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(request.flash[:info]).to be_nil
    end
  end

  context 'when the email is already in use' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should not create the account' do
      post :create, :user => { :email => user.email, :password => user.password }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(request.flash[:danger]).to match(/email in use/)
    end
  end

  context 'when the email is invalid' do
    render_views

    let(:user) { FactoryGirl.build(:user) }

    it 'should not create the account' do
      post :create, :user => { :email => 'invalid_email', :password => user.password }

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(response.body).to match(/Email is invalid/)
    end
  end

  context 'when the email and password are valid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should create the account' do
      post :create, :user => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(root_url)
    end
  end
end

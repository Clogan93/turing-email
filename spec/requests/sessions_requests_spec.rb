require 'rails_helper'

describe SessionsController, :type => :request do
  context 'when the user is not signed in' do
    it 'should render the signin page' do
      get signin_path

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when the username and password is invalid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should not login the user' do
      post sessions_path, :session => { :email => user.email, :password => user.password }

      expect(response).to render_template('new')
      expect(response.cookies['auth_key']).to eq(nil)
      expect(request.flash[:danger]).to match(/Invalid email\/password combination/)
    end
  end

  context 'when the password is invalid' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should increment the login attempt counter' do
      expect(user.login_attempt_count).to eq(0)

      post sessions_path, :session => { :email => user.email, :password => "#{user.password} invalid" }

      expect(response).to render_template('new')
      expect(response.cookies['auth_key']).to eq(nil)
      expect(request.flash[:danger]).to match(/Invalid email\/password combination/)

      user.reload
      expect(user.login_attempt_count).to eq(1)
    end
  end

  context 'when the there are too many invalid password attemps the account should be locked' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should increment the login attempt counter' do
      expect(user.login_attempt_count).to eq(0)

      (1..$config.max_login_attempts).each do
        post sessions_path, :session => { :email => user.email, :password => "#{user.password} invalid" }

        expect(response).to render_template('new')
        expect(response.cookies['auth_key']).to eq(nil)
        expect(request.flash[:danger]).to match(/Invalid email\/password combination/)
      end

      user.reload
      expect(user.login_attempt_count).to eq($config.max_login_attempts)

      post sessions_path, :session => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(reset_password_path)
      expect(response.cookies['auth_key']).to eq(nil)
      expect(request.flash[:danger]).to match(/Your account has been locked/)

      user.reload
      expect(user.login_attempt_count).to eq($config.max_login_attempts)
    end
  end

  context 'when the account is locked' do
    let(:user) { FactoryGirl.create(:locked_user) }

    it 'should not login the user' do
      post sessions_path, :session => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(reset_password_path)
      expect(response.cookies['auth_key']).to eq(nil)
      expect(request.flash[:danger]).to match(/Your account has been locked/)
    end
  end

  context 'when the username and password is valid' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should login the user' do
      post sessions_path, :session => { :email => user.email, :password => user.password }

      expect(response).to redirect_to(root_url)
      expect(response.cookies['auth_key']).to_not eq(nil)
    end
  end

  context 'when the user is signed in' do
    let(:user) { FactoryGirl.create(:user) }
    before { post sessions_path, :session => { :email => user.email, :password => user.password } }

    it 'should logout the user' do
      delete signout_path

      expect(response).to redirect_to(root_url)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when there user is not signed in' do
    it 'logout should still succeed' do
      delete signout_path

      expect(response).to redirect_to(root_url)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end
end

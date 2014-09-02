require 'rails_helper'

describe Api::V1::EmailsController, :type => :request do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:email_other) { FactoryGirl.create(:email) }

  context 'when the user is NOT signed in' do
    it 'should NOT show the email' do
      get "/api/v1/emails/#{email.uid}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is signed in' do
    before { post '/api/v1/sessions', :email => email.user.email, :password => email.user.password }

    it 'should show the email' do
      get "/api/v1/emails/#{email.uid}"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email.uid)
      expect(email_rendered['uid']).not_to eq(email_other.uid)
    end

    it 'should NOT show the other email' do
      get "/api/v1/emails/#{email_other.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end

  context 'when the other user is signed in' do
    before { post '/api/v1/sessions', :email => email_other.user.email, :password => email_other.user.password }

    it 'should show the other email' do
      get "/api/v1/emails/#{email_other.uid}"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email_other.uid)
      expect(email_rendered['uid']).not_to eq(email.uid)
    end

    it 'should NOT show the email' do
      get "/api/v1/emails/#{email.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end
end
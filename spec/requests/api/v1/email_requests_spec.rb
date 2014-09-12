require 'rails_helper'

describe Api::V1::EmailsController, :type => :request do
  context 'when the user is NOT signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }
    
    it 'should NOT show the email' do
      get "/api/v1/emails/show/#{email.uid}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }
    
    before { post '/api/v1/sessions', :email => email.user.email, :password => email.user.password }

    it 'should show the email' do
      get "/api/v1/emails/show/#{email.uid}"
      
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email.uid)
      expect(email_rendered['uid']).not_to eq(email_other.uid)
    end

    it 'should NOT show the other email' do
      get "/api/v1/emails/show/#{email_other.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end

  context 'when the other user is signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }
    
    before { post '/api/v1/sessions', :email => email_other.user.email, :password => email_other.user.password }

    it 'should show the other email' do
      get "/api/v1/emails/show/#{email_other.uid}"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email_other.uid)
      expect(email_rendered['uid']).not_to eq(email.uid)
    end

    it 'should NOT show the email' do
      get "/api/v1/emails/show/#{email.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end
  
  context 'set_seen' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:emails_not_seen) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:emails_seen) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :seen => true) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    it 'should set seen to true' do
      emails_not_seen.each { |email| expect(email.seen).to be(false) }
      
      email_uids = Email.where(:id => emails_not_seen).pluck(:uid)
      post '/api/v1/emails/set_seen', :email_uids => email_uids, :seen => true
      
      emails_not_seen.each { |email| expect(email.reload.seen).to be(true) }
    end

    it 'should set seen to false' do
      emails_seen.each { |email| expect(email.seen).to be(true) }

      email_uids = Email.where(:id => emails_seen).pluck(:uid)
      post '/api/v1/emails/set_seen', :email_uids => email_uids, :seen => false

      emails_seen.each { |email| expect(email.reload.seen).to be(false) }
    end
  end
end

require 'rails_helper'

describe Api::V1::EmailsController, :type => :request do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:email_other) { FactoryGirl.create(:email) }

  context 'when the user is NOT signed in' do
    it 'should NOT show the email' do
      get "/api/v1/emails/#{email.email_account_type}/#{email.email_account_id}/#{email.uid}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is signed in' do
    before { post '/api/v1/sessions', :email => email.user.email, :password => email.user.password }

    it 'should show the email' do
      get "/api/v1/emails/#{email.email_account_type}/#{email.email_account_id}/#{email.uid}"
      
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email.uid)
      expect(email_rendered['uid']).not_to eq(email_other.uid)
    end

    it 'should NOT show the other email' do
      get "/api/v1/emails/#{email_other.email_account_type}/#{email_other.email_account_id}/#{email_other.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end

  context 'when the other user is signed in' do
    before { post '/api/v1/sessions', :email => email_other.user.email, :password => email_other.user.password }

    it 'should show the other email' do
      get "/api/v1/emails/#{email_other.email_account_type}/#{email_other.email_account_id}/#{email_other.uid}"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email_other.uid)
      expect(email_rendered['uid']).not_to eq(email.uid)
    end

    it 'should NOT show the email' do
      get "/api/v1/emails/#{email.email_account_type}/#{email.email_account_id}/#{email.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end
  
  context 'ip_stats' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:emails_no_ip) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE, :email_account => gmail_account) }
    
    let!(:ip_infos) { FactoryGirl.create_list(:ip_info, 2) }

    let!(:emails_ip_1) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                                 :email_account => gmail_account, :ip_info => ip_infos[0]) }
    let!(:emails_ip_2) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                                 :email_account => gmail_account, :ip_info => ip_infos[1]) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    it 'should return email sender IP statistics' do
      get '/api/v1/emails/ip_stats'
      email_ip_stats = JSON.parse(response.body)
      expect(email_ip_stats.length).to eq(2)

      if (email_ip_stats[0]['ip_info']['ip'] == ip_infos[0].ip.to_s)
        email_ip_stats_1 = email_ip_stats[0]
        email_ip_stats_2 = email_ip_stats[1]
      else
        email_ip_stats_1 = email_ip_stats[1]
        email_ip_stats_2 = email_ip_stats[0]
      end

      expect(email_ip_stats_1['num_emails']).to eq(SpecMisc::TINY_LIST_SIZE)
      validate_ip_info(ip_infos[0], email_ip_stats_1['ip_info'])
      
      expect(email_ip_stats_2['num_emails']).to eq(SpecMisc::SMALL_LIST_SIZE)
      validate_ip_info(ip_infos[1], email_ip_stats_2['ip_info'])
    end
  end

  context 'top_contacts' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    
    let(:emails_tiny) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let(:emails_small) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE, :email_account => gmail_account) }
    let(:emails_medium) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
    
    let(:person_tiny) { FactoryGirl.create(:person, :email_account => gmail_account) }
    let(:person_small) { FactoryGirl.create(:person, :email_account => gmail_account) }
    let(:person_medium) { FactoryGirl.create(:person, :email_account => gmail_account) }
    
    before {
      emails_tiny.each { |email| FactoryGirl.create(:email_recipient, :email => email, :person => person_tiny,
                                                    :recipient_type => EmailRecipient.recipient_types[:to]) }

      emails_small.each { |email| FactoryGirl.create(:email_recipient, :email => email, :person => person_small,
                                                     :recipient_type => EmailRecipient.recipient_types[:to]) }

      emails_medium.each { |email| FactoryGirl.create(:email_recipient, :email => email, :person => person_medium,
                                                      :recipient_type => EmailRecipient.recipient_types[:to]) }
    }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    it 'should return top contact stats' do
      get '/api/v1/emails/top_contacts'
    end
  end
end

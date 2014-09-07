require 'rails_helper'

describe Api::V1::EmailsController, :type => :request do
  context 'when the user is NOT signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }
    
    it 'should NOT show the email' do
      get "/api/v1/emails/#{email.email_account_type}/#{email.email_account_id}/#{email.uid}"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  context 'when the user is signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }
    
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
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }
    
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

  context 'volume_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'no senders or recipients' do
      it 'should return top contact stats' do
        get '/api/v1/emails/volume_report'

        volume_report_stats = JSON.parse(response.body)

        expect(volume_report_stats[:received_emails_per_month]).to eq(nil)
        expect(volume_report_stats[:received_emails_per_week]).to eq(nil)
        expect(volume_report_stats[:received_emails_per_day]).to eq(nil)

        expect(volume_report_stats[:sent_emails_per_month]).to eq(nil)
        expect(volume_report_stats[:sent_emails_per_week]).to eq(nil)
        expect(volume_report_stats[:sent_emails_per_day]).to eq(nil)
      end
    end
  end
  
  context 'top_contacts' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    context 'no senders or recipients' do      
      it 'should return top contact stats' do
        get '/api/v1/emails/top_contacts'

        top_contacts_stats = JSON.parse(response.body)

        top_recipients = top_contacts_stats['top_recipients']
        expect(top_recipients).to eq({})

        top_senders = top_contacts_stats['top_senders']
        expect(top_senders).to eq({})
      end
    end
    
    context 'with senders and recipients' do
      let!(:sent_folder) { FactoryGirl.create(:gmail_label_sent, :gmail_account => gmail_account) }

      let(:recipient_counts) { [SpecMisc::MEDIUM_LIST_SIZE, SpecMisc::SMALL_LIST_SIZE, SpecMisc::TINY_LIST_SIZE] }
      let(:recipients) { [] }

      let(:sender_counts)  { [SpecMisc::MEDIUM_LIST_SIZE, SpecMisc::SMALL_LIST_SIZE, SpecMisc::TINY_LIST_SIZE] }
      let(:senders) { [] }
      
      def generate_top_contact_emails(num_emails, folder = nil)
        person = FactoryGirl.create(:person, :email_account => gmail_account)
        emails = FactoryGirl.create_list(:email, num_emails, :email_account => gmail_account,
                                         :from_address => person.email_address)

        emails.each do |email|
          FactoryGirl.create(:email_recipient, :email => email, :person => person,
                             :recipient_type => EmailRecipient.recipient_types[:to])

          properties = { :email => email }
          properties[:email_folder] = folder if folder
          FactoryGirl.create(:email_folder_mapping, properties)
        end
        
        return emails, person
      end

      before {
        recipient_counts.each do |recipient_count|
          emails_sent, person = generate_top_contact_emails(recipient_count, sent_folder)
          recipients << {:emails_sent => emails_sent, :person => person}
        end
        
        sender_counts.each do |sender_count|
          emails_received, person = generate_top_contact_emails(sender_count)
          senders << {:emails_received => emails_received, :person => person}
        end
      }

      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should return top contact stats' do
        get '/api/v1/emails/top_contacts'

        top_contacts_stats = JSON.parse(response.body)

        top_recipients = top_contacts_stats['top_recipients']
        expect(top_recipients.keys.length).to eq(recipients.length)
        
        top_recipients.zip(recipients).each do |top_recipient, recipient|
          expect(top_recipient[0]).to eq(recipient[:person].email_address)
          expect(top_recipient[1]).to eq(recipient[:emails_sent].length)
        end

        top_senders = top_contacts_stats['top_senders']
        expect(top_senders.keys.length).to eq(senders.length)
        
        top_senders.zip(senders).each do |top_sender, sender|
          expect(top_sender[0]).to eq(sender[:person].email_address)
          expect(top_sender[1]).to eq(sender[:emails_received].length)
        end
      end
    end
  end
end

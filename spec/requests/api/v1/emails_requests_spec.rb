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
  
  context 'ip_stats' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    
    context 'no emails' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should return email sender IP statistics' do
        get '/api/v1/emails/ip_stats'
        email_ip_stats = JSON.parse(response.body)
        expect(email_ip_stats.length).to eq(0)
      end
    end
    
    context 'with emails' do
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
  end

  context 'volume_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'no emails' do
      it 'should return volume report stats' do
        get '/api/v1/emails/volume_report'

        volume_report_stats = JSON.parse(response.body)

        expect(volume_report_stats['received_emails_per_month']).to eq({})
        expect(volume_report_stats['received_emails_per_week']).to eq({})
        expect(volume_report_stats['received_emails_per_day']).to eq({})

        expect(volume_report_stats['sent_emails_per_month']).to eq({})
        expect(volume_report_stats['sent_emails_per_week']).to eq({})
        expect(volume_report_stats['sent_emails_per_day']).to eq({})
      end
    end

    context 'with emails' do
      let!(:sent_folder) { FactoryGirl.create(:gmail_label_sent, :gmail_account => gmail_account) }
      
      let!(:today) { DateTime.now.utc }
      let!(:last_month) { today - 1.month }
      
      let!(:emails_received_today) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                                             :date => DateTime.now,
                                                             :email_account => gmail_account) }
      let!(:emails_received_last_month) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                                                  :date => last_month,
                                                                  :email_account => gmail_account) }

      let!(:emails_sent_today) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                                         :date => DateTime.now,
                                                         :email_account => gmail_account) }
      let!(:emails_sent_last_month) { FactoryGirl.create_list(:email, SpecMisc::SMALL_LIST_SIZE,
                                                              :date => last_month,
                                                              :email_account => gmail_account) }

      let!(:today_str) { today.strftime($config.volume_report_date_format) }
      let!(:today_week_str) { today.at_beginning_of_week.strftime($config.volume_report_date_format) }
      let!(:today_month_str) { today.at_beginning_of_month.strftime($config.volume_report_date_format) }
      let!(:last_month_str) { last_month.strftime($config.volume_report_date_format) }
      let!(:last_month_week_str) { last_month.at_beginning_of_week.strftime($config.volume_report_date_format) }
      let!(:last_month_month_str) { last_month.at_beginning_of_month.strftime($config.volume_report_date_format) }
      
      before {
        create_email_folder_mappings(emails_sent_today, sent_folder)
        create_email_folder_mappings(emails_sent_last_month, sent_folder)
      }

      it 'should return volume report stats' do
        get '/api/v1/emails/volume_report'

        volume_report_stats = JSON.parse(response.body)
        
        received_emails_per_month = volume_report_stats['received_emails_per_month']
        received_emails_per_week = volume_report_stats['received_emails_per_week']
        received_emails_per_day = volume_report_stats['received_emails_per_day']
        
        expect(received_emails_per_month.length).to eq(2)
        expect(received_emails_per_week.length).to eq(2)
        expect(received_emails_per_day.length).to eq(2)
        
        expect(received_emails_per_month[today_month_str]).to eq(emails_received_today.length)
        expect(received_emails_per_month[last_month_month_str]).to eq(emails_received_last_month.length)
        expect(received_emails_per_week[today_week_str]).to eq(emails_received_today.length)
        expect(received_emails_per_week[last_month_week_str]).to eq(emails_received_last_month.length)
        expect(received_emails_per_day[today_str]).to eq(emails_received_today.length)
        expect(received_emails_per_day[last_month_str]).to eq(emails_received_last_month.length)

        sent_emails_per_month = volume_report_stats['sent_emails_per_month']
        sent_emails_per_week = volume_report_stats['sent_emails_per_week']
        sent_emails_per_day = volume_report_stats['sent_emails_per_day']

        expect(sent_emails_per_month.length).to eq(2)
        expect(sent_emails_per_week.length).to eq(2)
        expect(sent_emails_per_day.length).to eq(2)

        expect(sent_emails_per_month[today_month_str]).to eq(emails_sent_today.length)
        expect(sent_emails_per_month[last_month_month_str]).to eq(emails_sent_last_month.length)
        expect(sent_emails_per_week[today_week_str]).to eq(emails_sent_today.length)
        expect(sent_emails_per_week[last_month_week_str]).to eq(emails_sent_last_month.length)
        expect(sent_emails_per_day[today_str]).to eq(emails_sent_today.length)
        expect(sent_emails_per_day[last_month_str]).to eq(emails_sent_last_month.length)
      end
    end
  end
  
  context 'contacts_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    context 'no senders or recipients' do      
      it 'should return top contact stats' do
        get '/api/v1/emails/contacts_report'

        contacts_report = JSON.parse(response.body)

        top_recipients = contacts_report['top_recipients']
        expect(top_recipients).to eq({})

        top_senders = contacts_report['top_senders']
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
        create_email_folder_mappings(emails, folder)
        
        emails.each do |email|
          FactoryGirl.create(:email_recipient, :email => email, :person => person,
                             :recipient_type => EmailRecipient.recipient_types[:to])
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
        get '/api/v1/emails/contacts_report'

        contacts_report_stats = JSON.parse(response.body)

        top_recipients = contacts_report_stats['top_recipients']
        expect(top_recipients.keys.length).to eq(recipients.length)
        
        top_recipients.zip(recipients).each do |top_recipient, recipient|
          expect(top_recipient[0]).to eq(recipient[:person].email_address)
          expect(top_recipient[1]).to eq(recipient[:emails_sent].length)
        end

        top_senders = contacts_report_stats['top_senders']
        expect(top_senders.keys.length).to eq(senders.length)
        
        top_senders.zip(senders).each do |top_sender, sender|
          expect(top_sender[0]).to eq(sender[:person].email_address)
          expect(top_sender[1]).to eq(sender[:emails_received].length)
        end

        bottom_recipients = contacts_report_stats['bottom_recipients']
        expect(bottom_recipients.keys.length).to eq(recipients.length)

        bottom_recipients.zip(recipients.reverse).each do |bottom_recipient, recipient|
          expect(bottom_recipient[0]).to eq(recipient[:person].email_address)
          expect(bottom_recipient[1]).to eq(recipient[:emails_sent].length)
        end

        bottom_senders = contacts_report_stats['bottom_senders']
        expect(bottom_senders.keys.length).to eq(senders.length)

        bottom_senders.zip(senders.reverse).each do |bottom_sender, sender|
          expect(bottom_sender[0]).to eq(sender[:person].email_address)
          expect(bottom_sender[1]).to eq(sender[:emails_received].length)
        end
      end
    end
  end
  
  context 'attachments_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'no attachments' do
      it 'should return attachments report stats' do
        get '/api/v1/emails/attachments_report'

        attachments_report_stats = JSON.parse(response.body)

        expect(attachments_report_stats['average_file_size']).to eq(0)
        expect(attachments_report_stats['content_type_stats']).to eq({})
      end
    end

    context 'with attachents' do
      let!(:email) { FactoryGirl.create(:email, :email_account => gmail_account) }
      let!(:email_attachments) { FactoryGirl.create_list(:email_attachment, SpecMisc::SMALL_LIST_SIZE, :email => email) }
      let!(:jpeg_file_size) { 50 }
      let!(:email_attachments_jpegs) { FactoryGirl.create_list(:email_attachment, SpecMisc::SMALL_LIST_SIZE,
                                                               :email => email,
                                                               :content_type => 'image/jpeg', :file_size => jpeg_file_size) }
      let!(:bmp_1_size) { 2 }
      let!(:bmp_2_size) { 4 }
      let!(:email_attachment_bmp_1) { FactoryGirl.create(:email_attachment, :email => email,
                                                         :content_type => 'image/bmp', :file_size => bmp_1_size) }
      let!(:email_attachment_bmp_2) { FactoryGirl.create(:email_attachment, :email => email,
                                                         :content_type => 'image/bmp', :file_size => bmp_2_size) }
      
      it 'should return attachments report stats' do
        get '/api/v1/emails/attachments_report'
        
        attachments_report_stats = JSON.parse(response.body)
        default = email_attachments.first
        jpeg = email_attachments_jpegs.first

        average_file_size_expected = (default.file_size * email_attachments.length +
                                      jpeg.file_size * email_attachments_jpegs.length +
                                      bmp_1_size + bmp_2_size) /
                                     (email_attachments.length + email_attachments_jpegs.length + 2) 
        expect(attachments_report_stats['average_file_size']).to eq(average_file_size_expected)

        content_type_stats = attachments_report_stats['content_type_stats']
        expect(content_type_stats.length).to eq(3)
        
        default_stats = content_type_stats[default.content_type]
        expect(default_stats['average_file_size']).to eq(default.file_size)
        expect(default_stats['num_attachments']).to eq(email_attachments.length)

        jpeg_stats = content_type_stats[jpeg.content_type]
        expect(jpeg_stats['average_file_size']).to eq(jpeg.file_size)
        expect(jpeg_stats['num_attachments']).to eq(email_attachments_jpegs.length)

        bmp_stats = content_type_stats[email_attachment_bmp_1.content_type]
        expect(bmp_stats['average_file_size']).to eq((bmp_1_size + bmp_2_size) / 2)
        expect(bmp_stats['num_attachments']).to eq(2)
      end
    end
  end
end

require 'rails_helper'

describe Api::V1::EmailsController, :type => :request do
  describe '#ip_stats_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    
    context 'no emails' do
      before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should return email sender IP statistics' do
        get '/api/v1/email_reports/ip_stats_report'
        email_ip_stats = JSON.parse(response.body)["ip_stats"]
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
        get '/api/v1/email_reports/ip_stats_report'
        email_ip_stats = JSON.parse(response.body)["ip_stats"]
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

  describe '#volume_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'no emails' do
      it 'should return volume report stats' do
        get '/api/v1/email_reports/volume_report'

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
        get '/api/v1/email_reports/volume_report'

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

  describe '#contacts_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
    
    context 'no senders or recipients' do      
      it 'should return top contact stats' do
        get '/api/v1/email_reports/contacts_report'

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
        get '/api/v1/email_reports/contacts_report'

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

  describe '#attachments_report' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'no attachments' do
      it 'should return attachments report stats' do
        get '/api/v1/email_reports/attachments_report'

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
        get '/api/v1/email_reports/attachments_report'
        
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
  
  describe '#lists_report' do
    let(:gmail_account) { FactoryGirl.create(:gmail_account) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'without emails' do
      it 'returns the lists report stats' do
        get '/api/v1/email_reports/lists_report'

        lists_report_stats = JSON.parse(response.body)

        expect(lists_report_stats['lists_email_daily_average'].length).to eq(0)

        expect(lists_report_stats['emails_per_list'].length).to eq(0)

        expect(lists_report_stats['email_threads_per_list'].length).to eq(0)

        expect(lists_report_stats['email_threads_replied_to_per_list'].length).to eq(0)
      end
    end

    context 'with emails' do
      let!(:today) { DateTime.now.utc }
      let!(:yesterday) { today - 2.day }

      let!(:today_str) { today.strftime($config.volume_report_date_format) }
      let!(:yesterday_str) { yesterday.strftime($config.volume_report_date_format) }
      
      let(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      
      before do
        email_threads.each_with_index do |email_thread, i|
          FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE,
                                  :email_thread => email_thread,
                                  :email_account => gmail_account,
                                  :date => today,
                                  :list_id => "foo#{i}.bar.com")

          FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE * (i + 1),
                                  :email_thread => email_thread,
                                  :email_account => gmail_account,
                                  :date => yesterday,
                                  :list_id => "foo#{i}.bar.com")
        end
      end
      
      it 'returns the lists report stats' do
        get '/api/v1/email_reports/lists_report'

        lists_report_stats = JSON.parse(response.body)

        lists_report_stats['lists_email_daily_average'].each do |list_email_daily_average|
          i = list_email_daily_average[1].match(/(\d)/)[1].to_i
          expect(list_email_daily_average[2]).to eq((SpecMisc::TINY_LIST_SIZE + SpecMisc::TINY_LIST_SIZE * (i + 1)) / 2.0)
        end

        lists_report_stats['emails_per_list'].each do |email_list_stats|
          i = email_list_stats[1].match(/(\d)/)[1].to_i
          expect(email_list_stats[2]).to eq(SpecMisc::TINY_LIST_SIZE + SpecMisc::TINY_LIST_SIZE * (i + 1))
        end

        lists_report_stats['email_threads_per_list'].each do |email_thread_list_stats|
          expect(email_thread_list_stats[2]).to eq(1)
        end

        lists_report_stats['email_threads_replied_to_per_list'].each do |email_thread_replied_to_list_stats|
          i = email_thread_replied_to_list_stats[1].match(/(\d)/)[1].to_i
          expect(email_thread_replied_to_list_stats[2]).to eq(SpecMisc::TINY_LIST_SIZE + SpecMisc::TINY_LIST_SIZE * (i + 1))
        end
      end
    end
  end

  describe '#threads_report' do
    let(:gmail_account) { FactoryGirl.create(:gmail_account) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'without emails' do
      it 'returns the threads report stats' do
        get '/api/v1/email_reports/threads_report'

        threads_report_stats = JSON.parse(response.body)

        expect(threads_report_stats['average_thread_length']).to eq(0)
      end
    end

    context 'with emails' do
      let(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      
      before do
        num_emails = 1
        
        email_threads.each do |email_thread|
          create_email_thread_emails([email_thread], num_emails: num_emails)
          num_emails += 1
        end
      end
      
      let!(:num_emails) { email_threads.length * (email_threads.length + 1) / 2 }
      
      it 'returns the threads report stats' do
        get '/api/v1/email_reports/threads_report'
  
        threads_report_stats = JSON.parse(response.body)
        
        expect(threads_report_stats['average_thread_length']).to eq(num_emails / email_threads.length)
        verify_models_expected(email_threads.reverse, threads_report_stats['top_email_threads'], 'uid')
      end
    end
  end

  describe '#folders_report' do
    let(:gmail_account) { FactoryGirl.create(:gmail_account) }
    
    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'without emails' do
      it 'returns the folders report stats' do
        get '/api/v1/email_reports/folders_report'

        folders_report_stats = JSON.parse(response.body)

        expect(folders_report_stats['percent_inbox']).to eq(0)
        expect(folders_report_stats['percent_unread']).to eq(0)
        expect(folders_report_stats['percent_sent']).to eq(0)
        expect(folders_report_stats['percent_draft']).to eq(0)
        expect(folders_report_stats['percent_trash']).to eq(0)
        expect(folders_report_stats['percent_spam']).to eq(0)
        expect(folders_report_stats['percent_starred']).to eq(0)
      end
    end
    
    context 'with emails' do
      let(:other_emails) { FactoryGirl.create_list(:email, SpecMisc::LARGE_LIST_SIZE) }
      
      let!(:inbox_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      let!(:read_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account, :seen => true) }
      let!(:sent_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      let!(:draft_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      let!(:trash_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      let!(:spam_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      let!(:starred_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      
      let!(:inbox_folder) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
      let!(:sent_folder) { FactoryGirl.create(:gmail_label_sent, :gmail_account => gmail_account) }
      let!(:drafts_folder) { FactoryGirl.create(:gmail_label_drafts, :gmail_account => gmail_account) }
      let!(:trash_folder) { FactoryGirl.create(:gmail_label_trash, :gmail_account => gmail_account) }
      let!(:spam_folder) { FactoryGirl.create(:gmail_label_spam, :gmail_account => gmail_account) }
      let!(:starred_folder) { FactoryGirl.create(:gmail_label_starred, :gmail_account => gmail_account) }

      before do
        create_email_folder_mappings(inbox_emails, inbox_folder)
        create_email_folder_mappings(sent_emails, sent_folder)
        create_email_folder_mappings(draft_emails, drafts_folder)
        create_email_folder_mappings(trash_emails, trash_folder)
        create_email_folder_mappings(spam_emails, spam_folder)
        create_email_folder_mappings(starred_emails, starred_folder)
      end
  
      it 'returns the folders report stats' do
        get '/api/v1/email_reports/folders_report'
        
        folders_report_stats = JSON.parse(response.body)
        
        expect(folders_report_stats['percent_inbox']).to eq(inbox_emails.length / gmail_account.emails.count.to_f)
        expect(folders_report_stats['percent_unread']).to eq(gmail_account.emails.count - read_emails.length)
        expect(folders_report_stats['percent_sent']).to eq(sent_emails.length / gmail_account.emails.count.to_f)
        expect(folders_report_stats['percent_draft']).to eq(draft_emails.length / gmail_account.emails.count.to_f)
        expect(folders_report_stats['percent_trash']).to eq(trash_emails.length / gmail_account.emails.count.to_f)
        expect(folders_report_stats['percent_spam']).to eq(spam_emails.length / gmail_account.emails.count.to_f)
        expect(folders_report_stats['percent_starred']).to eq(starred_emails.length / gmail_account.emails.count.to_f)
      end
    end
  end

  describe '#impact_report' do
    let(:gmail_account) { FactoryGirl.create(:gmail_account) }

    before { post '/api/v1/sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

    context 'without emails' do
      it 'returns the impact report stats' do
        get '/api/v1/email_reports/impact_report'

        impact_report_stats = JSON.parse(response.body)

        expect(impact_report_stats['percent_sent_emails_replied_to']).to eq(0)
      end
    end
    
    context 'with emails' do
      let!(:sent_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      let!(:sent_folder) { FactoryGirl.create(:gmail_label_sent, :gmail_account => gmail_account) }

      let!(:reply_emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
      
      before do
        create_email_folder_mappings(sent_emails, sent_folder)
        
        reply_emails.zip(sent_emails).each do |email, sent_email|
          FactoryGirl.create(:email_in_reply_to, :email => email, :in_reply_to_message_id => sent_email.message_id)
        end
      end
      
      it 'returns the impact report stats' do
        get '/api/v1/email_reports/impact_report'

        impact_report_stats = JSON.parse(response.body)

        expect(impact_report_stats['percent_sent_emails_replied_to']).to eq(reply_emails.length / sent_emails.length.to_f)
      end
    end
  end
end

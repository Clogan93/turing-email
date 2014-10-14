require 'rails_helper'

describe Email, :type => :model do
  describe '#Email.lists_email_daily_average' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    
    context 'without emails' do
      it 'returns the lists report stats' do
        lists_email_daily_average = Email.lists_email_daily_average(gmail_account.user)
        expect(lists_email_daily_average.length).to eq(0)
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
        lists_email_daily_average = Email.lists_email_daily_average(gmail_account.user)
        
        lists_email_daily_average.each do |list_email_daily_average|
          i = list_email_daily_average[1].match(/(\d)/)[1].to_i
          expect(list_email_daily_average[2]).to eq((SpecMisc::TINY_LIST_SIZE + SpecMisc::TINY_LIST_SIZE * (i + 1)) / 2.0)
        end
      end
    end
  end
  
  describe '#Email.trash_emails' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:trash_label) { FactoryGirl.create(:gmail_label_trash, :gmail_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
    
    before { gmail_label.apply_to_emails(emails) }
    
    it 'should move emails to the trash folder' do
      expect(gmail_label.emails.length).to eq(emails.length)
      expect(trash_label.emails.length).to eq(0)
      
      Email.trash_emails(emails, trash_label)
      
      gmail_label.reload
      trash_label.reload

      expect(gmail_label.emails.length).to eq(0)
      expect(trash_label.emails.length).to eq(emails.length)
    end
  end
  
  describe '#Email.email_raw_from_params' do
    let!(:email_raw) { Mail.new }
    let!(:parent_email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, :email => parent_email) }
    let!(:email_references) { FactoryGirl.create_list(:email_reference, SpecMisc::TINY_LIST_SIZE, :email => parent_email) }
    
    it 'creates the email' do
      email_raw, email_in_reply_to = Email.email_raw_from_params('to@to.com', 'cc@cc.com', 'bcc@bcc.com',
                                                                 'subject', 'html_part', 'text_part',
                                                                 parent_email.email_account, parent_email.uid)
      expect(email_raw.to).to eq(['to@to.com'])
      expect(email_raw.cc).to eq(['cc@cc.com'])
      expect(email_raw.bcc).to eq(['bcc@bcc.com'])
      expect(email_raw.subject).to eq('subject')
      expect(email_raw.html_part.decoded).to eq('html_part')
      expect(email_raw.text_part.decoded).to eq('text_part')

      # reply headers
      expect(email_raw.in_reply_to).to eq(parent_email.message_id)

      expect(email_raw.references.length).to eq(email_references.length + 1)

      email_references.each_with_index do |email_reference, position|
        expect(email_raw.references[position]).to eq(email_reference.references_message_id)
      end

      expect(email_raw.references.last).to eq(parent_email.message_id)
    end
  end
  
  describe 'Email creation' do
    def validate_default_email(email)
      expect(email.ip_info.ip).to eq('50.197.164.77')

      expect(email.message_id).to eq('CAGxZP2OiRss-xbvSM4T48FdK=EmbdSyiOGDjXnk+mS6o5x50qA@mail.gmail.com')

      expect(email.list_name).to eq('The virtual soul of the Black Community at Stanford')
      expect(email.list_id).to eq('the_diaspora.lists.stanford.edu')

      expect(email.date).to eq('Thu, 18 Sep 2014 22:42:32 -0700')

      expect(email.from_name).to eq('Qounsel Digest')
      expect(email.from_address).to eq('digest@mail.qounsel.com')

      expect(email.sender_name).to eq('activists')
      expect(email.sender_address).to eq('activists-bounces@lists.stanford.edu')

      expect(email.reply_to_name).to eq('Reply to Comment')
      expect(email.reply_to_address).to eq('g+40wvnfci000000004t3f0067f3d796km0000009ooypx2pu46@groups.facebook.com')

      expect(email.tos).to eq('test@turinginc.com')
      expect(email.ccs).to eq('cc@cc.com')
      expect(email.bccs).to eq('bcc@bcc.com')
      expect(email.subject).to eq('test')

      expect(email.text_part).to eq("body\n")
      verify_premailer_html(email.html_part, "body\n")
      expect(email.body_text).to eq(nil)

      expect(email.has_calendar_attachment).to eq(true)
    end

    describe '#Email.email_raw_from_mime_data' do
      let(:mime_data) { File.read('spec/data/emails/raw/raw_email.txt') }
      let(:email_raw) { Email.email_raw_from_mime_data(mime_data) }
      let(:email) { Email.email_from_email_raw(email_raw) }

      it 'should load the email' do
        validate_default_email(email)
      end
    end

    describe '#Email.email_from_mime_data' do
      let(:mime_data) { File.read('spec/data/emails/raw/raw_email.txt') }
      let(:email) { Email.email_from_mime_data(mime_data) }
      
      it 'should load the email' do
        validate_default_email(email)
      end
    end
    
    describe '#Email.email_from_email_raw' do
      let(:email_raw) { Mail.read('spec/data/emails/raw/raw_email.txt') }
      let(:email) { Email.email_from_email_raw(email_raw) }

      it 'should load the email' do
        validate_default_email(email)
      end
    end
  end

  context '#Email.get_sender_ip' do
    context 'X-Originating-IP' do
      let(:email_raw) { Mail.new }
      before { email_raw.header = File.read('spec/data/emails/headers/x_originating_ip.txt') }
      
      it 'should get the sender IP from the X-Originating-IP header' do
        expect(Email.get_sender_ip(email_raw)).to eq('50.197.164.77')
      end
    end
  
    context 'Received-SPF' do
      let(:email_raw) { Mail.new }
      before { email_raw.header = File.read('spec/data/emails/headers/received_spf.txt') }
  
      it 'should get the sender IP from the Received-SPF header' do
        expect(Email.get_sender_ip(email_raw)).to eq('10.112.11.170')
      end
    end
  
    context 'Received' do
      let(:email_raw) { Mail.new }
      before { email_raw.header = File.read('spec/data/emails/headers/received.txt') }
  
      it 'should get the sender IP from the Received header' do
        expect(Email.get_sender_ip(email_raw)).to eq('66.220.144.136')
      end
    end
  end
  
  describe '#Email.part_has_calendar_attachment' do
    context 'has calendar attachment' do
      let(:email_raw) { Mail.read("spec/data/emails/calendar/has_calendar_attachment.txt") }
      
      it 'returns true' do
        expect(Email.part_has_calendar_attachment(email_raw)).to be(true)
      end
    end

    context 'no calendar attachment' do
      let(:email_raw) { Mail.read("spec/data/emails/calendar/no_calendar_attachment.txt") }

      it 'returns false' do
        expect(Email.part_has_calendar_attachment(email_raw)).to be(false)
      end
    end
  end

  describe '#Email.add_reply_headers' do
    let!(:email_raw) { Mail.new }
    let!(:parent_email) { FactoryGirl.create(:email) }
    let!(:email_in_reply_to) { FactoryGirl.create(:email_in_reply_to, :email => parent_email) }
    
    context 'has references' do
      let!(:email_references) { FactoryGirl.create_list(:email_reference, SpecMisc::TINY_LIST_SIZE, :email => parent_email) }
      
      before { Email.add_reply_headers(email_raw, parent_email) }
      
      it 'should add the reply headers' do
        expect(email_raw.in_reply_to).to eq(parent_email.message_id)

        expect(email_raw.references.length).to eq(email_references.length + 1)
        
        email_references.each_with_index do |email_reference, position|
          expect(email_raw.references[position]).to eq(email_reference.references_message_id)
        end
        
        expect(email_raw.references.last).to eq(parent_email.message_id)
      end
    end
    
    context 'no references' do
      before { Email.add_reply_headers(email_raw, parent_email) }
      
      it 'should add the reply headers' do
        expect(email_raw.in_reply_to).to eq(parent_email.message_id)

        expect(email_raw.references.length).to eq(2)
        expect(email_raw.references[0]).to eq(email_in_reply_to.in_reply_to_message_id)
        expect(email_raw.references[1]).to eq(parent_email.message_id)
      end
    end
  end
  
  describe '#user' do
    let(:email) { FactoryGirl.create(:email) }
    
    it 'returns the user' do
      expect(email.user).not_to be(nil)
    end
  end
  
  describe '#add_references' do
    let(:email) { FactoryGirl.create(:email) }
    let(:email_raw) { Mail.new }
    
    context 'valid references' do
      before { email_raw.header = File.read('spec/data/emails/headers/references/valid_references.txt') }
      before { email.add_references(email_raw) }
      
      it 'should add the references' do
        email_references = email.email_references.order(:position).pluck(:references_message_id)
        expect(email_references).to eq(['CAMwYsmtfTu-kF3c8WS6ioxatGAg+S9wYPmZVK9M3KvNLO_HRiw@mail.gmail.com',
                                        'CA+nRABmhcoTqWQvDcF--OkDGj6DkA8Ttc4eYOgKZW=EAp-5Ejw@mail.gmail.com',
                                        'CAMwYsmseaXEqWnxuNrjd0rmSrEkcCF5n9usAOhmt-xsqwBWLPA@mail.gmail.com'])
      end
    end

    context 'invalid reference' do
      before { email_raw.header = File.read('spec/data/emails/headers/references/invalid_reference.txt') }
      before { email.add_references(email_raw) }

      it 'should add the reference' do
        expect(email.email_references.first.references_message_id).to eq('hello')
      end
    end
  end

  describe '#add_in_reply_tos' do
    let(:email) { FactoryGirl.create(:email) }
    let(:email_raw) { Mail.new }

    context 'valid reply_to' do
      before { email_raw.header = File.read('spec/data/emails/headers/in_reply_tos/valid_reply_to.txt') }
      before { email.add_in_reply_tos(email_raw) }

      it 'should add the references' do
        expect(email.email_in_reply_tos.first.in_reply_to_message_id).to eq('CAMwYsmseaXEqWnxuNrjd0rmSrEkcCF5n9usAOhmt-xsqwBWLPA@mail.gmail.com')
      end
    end

    context 'invalid reply_to' do
      before { email_raw.header = File.read('spec/data/emails/headers/in_reply_tos/invalid_reply_to.txt') }
      before { email.add_in_reply_tos(email_raw) }

      it 'should add the reference' do
        expect(email.email_in_reply_tos.first.in_reply_to_message_id).to eq('hello')
      end
    end
  end
  
  describe '#add_attachments' do
    let(:email) { FactoryGirl.create(:email) }
    let(:email_raw) { Mail.read("spec/data/emails/with_attachments/email_1.txt") }
    
    before{ email.add_attachments(email_raw) }
    
    it 'should correctly add attachments' do
      email_attachment = email.email_attachments.first
      expect(email_attachment.filename).to eq('Health Promotions Specialist FTR92014 - APIWC.pdf')
      expect(email_attachment.content_type).to eq('application/pdf')
      expect(email_attachment.file_size).to eq(92918)
    end
  end
  
  describe '#add_recipients' do
    let(:recipients_expected) {
      {
          '1' => {
              :tos => [{ :name => 'the diaspora', :email_address => 'the_diaspora@lists.stanford.edu' },
                       { :name => nil, :email_address => 'sbse@lists.stanford.edu'} ],
              :ccs => [],
              :bccs => []
          },
          
          '2' => {
              :tos => [{ :name => 'Sam Bydlon', :email_address => 'sbydlon@stanford.edu' }],
              :ccs => [{ :name => 'gsc-members', :email_address => 'gsc-members@lists.stanford.edu' }],
              :bccs => []
          },
          
          '3' => {
              :tos => [],
              :ccs => [],
              :bccs => [{ :name => nil, :email_address => 'support@sendpluto.com' }]
          }
      }
    }

    it 'should correctly add recipients' do
      recipients_expected.each do |key, recipients|
        email = FactoryGirl.create(:email)
        email_raw = Mail.new
        email_raw.header = File.read("spec/data/emails/headers/recipients/recipients_#{key}.txt")
        
        email.add_recipients(email_raw)
        
        [['to', :tos], ['cc', :ccs], ['bcc', :bccs]].each do |recipient_scope, recipient_type|
          expect(email.email_recipients.send(recipient_scope).count).to eq(recipients[recipient_type].length)
          
          recipients[recipient_type].each do |recipient_expected|
            found = false
            
            email.email_recipients.send(recipient_scope).each do |recipient|
              found = recipient_expected[:name] == recipient.person.name &&
                      recipient_expected[:email_address] == recipient.person.email_address
              break if found
            end
            
            expect(found).to eq(true)
          end
        end
      end
    end
  end
  
  describe '#destroy' do
    let!(:email) { FactoryGirl.create(:email) }
    
    let!(:email_recipients) { FactoryGirl.create_list(:email_recipient, SpecMisc::TINY_LIST_SIZE, :email => email) }
    let!(:email_references) { FactoryGirl.create_list(:email_reference, SpecMisc::TINY_LIST_SIZE, :email => email) }
    let!(:email_in_reply_tos) { FactoryGirl.create_list(:email_in_reply_to, SpecMisc::TINY_LIST_SIZE, :email => email) }
    let!(:email_attachments) { FactoryGirl.create_list(:email_attachment, SpecMisc::TINY_LIST_SIZE, :email => email) }
    
    before { create_email_folder_mappings([email]) }
    
    it 'should destroy the associated models' do
      expect(EmailFolderMapping.where(:email => email).count).to eq(1)
      expect(EmailRecipient.where(:email => email).count).to eq(email_recipients.length)
      expect(EmailReference.where(:email => email).count).to eq(email_references.length)
      expect(EmailInReplyTo.where(:email => email).count).to eq(email_in_reply_tos.length)
      expect(EmailAttachment.where(:email => email).count).to eq(email_attachments.length)

      expect(email.destroy).not_to be(false)

      expect(EmailFolderMapping.where(:email => email).count).to eq(0)
      expect(EmailRecipient.where(:email => email).count).to eq(0)
      expect(EmailReference.where(:email => email).count).to eq(0)
      expect(EmailInReplyTo.where(:email => email).count).to eq(0)
      expect(EmailAttachment.where(:email => email).count).to eq(0)
    end
  end
end

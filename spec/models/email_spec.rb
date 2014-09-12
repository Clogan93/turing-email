require 'rails_helper'

describe Email, :type => :model do
  context 'trash_emails' do
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
  
  context 'Email.email_from_email_raw' do
    context 'parsing from address' do 
      let(:email_raw) { Mail.read('spec/data/emails/raw/raw_email_1.txt') }
      let(:email) { Email.email_from_email_raw(email_raw) }
      
      it 'should parse the from address' do
        expect(email.from_name).to eq('Qounsel Digest')
        expect(email.from_address).to eq('digest@mail.qounsel.com')
      end
    end
    
    context 'parsing reply_to address' do
      let(:email_raw) { Mail.read('spec/data/emails/raw/raw_email_2.txt') }
      let(:email) { Email.email_from_email_raw(email_raw) }

      it 'should parse the from address' do
        expect(email.reply_to_name).to eq('Reply to Comment')
        expect(email.reply_to_address).to eq('g+40wvnfci000000004t3f0067f3d796km0000009ooypx2pu46@groups.facebook.com')
      end
    end

    context 'parsing sender address' do
      let(:email_raw) { Mail.read('spec/data/emails/raw/raw_email_3.txt') }
      let(:email) { Email.email_from_email_raw(email_raw) }

      it 'should parse the from address' do
        expect(email.sender_name).to eq('activists')
        expect(email.sender_address).to eq('activists-bounces@lists.stanford.edu')
      end
    end
  end

  context 'Email.get_sender_ip' do
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
  
  context 'add_recipients' do
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
end

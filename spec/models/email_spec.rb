require 'rails_helper'

describe Email, :type => :model do
  context 'get_sender_ip' do
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
              :ccs => []
          },
          
          '2' => {
              :tos => [{ :name => 'Sam Bydlon', :email_address => 'sbydlon@stanford.edu' }],
              :ccs => [{ :name => 'gsc-members', :email_address => 'gsc-members@lists.stanford.edu' }]
          }
      }
    }

    it 'should correctly add recipients' do
      recipients_expected.each do |key, recipients|
        email = FactoryGirl.create(:email)
        email_raw = Mail.new
        email_raw.header = File.read("spec/data/emails/headers/recipients/recipients_#{key}.txt")
        
        email.add_recipients(email_raw)
        
        expect(email.email_recipients.to.count).to eq(recipients[:tos].length)
        expect(email.email_recipients.cc.count).to eq(recipients[:ccs].length)

        recipients[:tos].each do |to_recipient_expected|
          found = false
          
          email.email_recipients.to.each do |to_recipient|
            found = to_recipient_expected[:name] == to_recipient.person.name &&
                    to_recipient_expected[:email_address] == to_recipient.person.email_address
            break if found
          end
          
          expect(found).to eq(true)
        end
      end
    end
  end
end

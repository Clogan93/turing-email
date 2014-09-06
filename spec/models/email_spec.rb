require 'rails_helper'

describe Email, :type => :model do
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

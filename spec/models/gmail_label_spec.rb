require 'rails_helper'

describe GmailLabel, :type => :model do
  let(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let(:test_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
  let(:emails) { FactoryGirl.create_list(:email, 10, :email_account => gmail_account) }
  let(:emails_seen) { FactoryGirl.create_list(:seen_email, 10, :email_account => gmail_account) }

  context 'num_threads' do
    it 'should return 0 when there are no threads' do
      expect(test_label.num_threads).to eq(0)
    end

    it 'should return the number of threads when present' do
      emails.each { |email| FactoryGirl.create(:email_folder_mapping, :email => email, :email_folder => test_label) }
      expect(test_label.num_threads).to eq(emails.length)
    end
  end
end

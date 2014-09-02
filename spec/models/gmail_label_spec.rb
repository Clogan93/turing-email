require 'rails_helper'

describe GmailLabel, :type => :model do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let(:test_label) { FactoryGirl.create(:gmail_label, :gmail_account => email_account) }
  let(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }
  let(:emails_seen) { FactoryGirl.create_list(:seen_email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }

  context 'num_threads' do
    it 'should return the correct number of threads' do
      # each email by default is assigned to a unique thread

      expect(test_label.num_threads).to eq(0)

      emails.each { |email| FactoryGirl.create(:email_folder_mapping, :email => email, :email_folder => test_label) }
      expect(test_label.num_threads).to eq(emails.length)

      emails_seen.each { |email_seen| FactoryGirl.create(:email_folder_mapping,
                                                         :email => email_seen, :email_folder => test_label) }
      expect(test_label.num_threads).to eq(emails.length + emails_seen.length)
    end
  end

  context 'num_unread_threads' do
    it 'should return the correct number of unread threads' do
      expect(test_label.num_unread_threads).to eq(0)

      emails.each { |email| FactoryGirl.create(:email_folder_mapping, :email => email, :email_folder => test_label) }
      expect(test_label.num_unread_threads).to eq(emails.length)

      emails_seen.each { |email_seen| FactoryGirl.create(:email_folder_mapping,
                                                         :email => email_seen, :email_folder => test_label) }
      expect(test_label.num_unread_threads).to eq(emails.length)
    end
  end
end

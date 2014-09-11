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

      create_email_folder_mappings(emails, test_label)
      expect(test_label.num_threads).to eq(emails.length)

      create_email_folder_mappings(emails_seen, test_label)
      expect(test_label.num_threads).to eq(emails.length + emails_seen.length)
    end
  end

  context 'num_unread_threads' do
    it 'should return the correct number of unread threads' do
      expect(test_label.num_unread_threads).to eq(0)

      create_email_folder_mappings(emails, test_label)
      expect(test_label.num_unread_threads).to eq(emails.length)

      create_email_folder_mappings(emails_seen, test_label)
      expect(test_label.num_unread_threads).to eq(emails.length)
    end
  end

  context 'destroy' do
    let!(:email_account) { FactoryGirl.create(:gmail_account) }
    let!(:email_folder) { FactoryGirl.create(:gmail_label, :gmail_account => email_account) }
    let!(:email_threads) { FactoryGirl.create_list(:email_thread,
                                                   SpecMisc::TINY_LIST_SIZE,
                                                   :email_account => email_account) }

    let!(:emails) { create_email_thread_emails(email_threads, email_folder) }

    it 'should destroy the email folder mappings but not the emails' do
      expect(EmailThread.where(:email_account => email_account).count).to eq(email_threads.length)
      expect(Email.where(:email_account => email_account).count).to eq(emails.length)
      expect(EmailFolderMapping.where(:email_id => email_account.emails.pluck(:id)).count).to eq(emails.length)
      expect(email_account.gmail_labels.count).to eq(1)

      expect(email_folder.emails.count).to eq(emails.length)
      expect(email_folder.destroy).not_to eq(false)

      expect(EmailThread.where(:email_account => email_account).count).to eq(email_threads.length)
      expect(Email.where(:email_account => email_account).count).to eq(emails.length)
      expect(EmailFolderMapping.where(:email_id => email_account.emails.pluck(:id)).count).to eq(0)
      expect(email_account.gmail_labels.count).to eq(0)
    end
  end
end

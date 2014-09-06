require 'rails_helper'

describe EmailThread, :type => :model do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }
  let!(:email_threads_other) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }

  context 'get_threads_from_ids' do
    it 'should return the correct threads' do
      email_threads_ids = email_threads.map { |email_thread| email_thread.id }
      email_threads_found = EmailThread.get_threads_from_ids(email_threads_ids)
      verify_models_expected(email_threads, email_threads_found, 'id')
      verify_models_unexpected(email_threads_other, email_threads_found, 'id')

      email_threads_other_ids = email_threads_other.map { |email_thread_other| email_thread_other.id }
      email_threads_found = EmailThread.get_threads_from_ids(email_threads_other_ids)
      verify_models_expected(email_threads_other, email_threads_found, 'id')
      verify_models_unexpected(email_threads, email_threads_found, 'id')
    end
  end

  context 'destroy' do
    let(:emails) { create_email_thread_emails(email_account, email_threads) }

    it 'should destroy the emails' do
      num_emails = emails.length
      expect(Email.where(:email_account => email_account).count).to eq(num_emails)

      email_threads.each do |email_thread|
        num_emails -= email_thread.emails.count
        expect(email_thread.destroy).not_to eq(false)
        expect(Email.where(:email_account => email_account).count).to eq(num_emails)
      end

      expect(Email.where(:email_account => email_account).count).to eq(0)
    end
  end
end

require 'rails_helper'

describe EmailThread, :type => :model do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }
  let!(:email_threads_other) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => email_account) }

  context 'validations' do
    it 'should fail to save without an email account and uid' do
      email_thread = EmailThread.new
      expect(email_thread.save).to be(false)

      email_thread.email_account = email_account
      expect(email_thread.save).to be(false)

      email_thread.uid = '123'
      expect(email_thread.save).to be(true)
    end
  end
  
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

  describe '#user' do
    let(:email_thread) { FactoryGirl.create(:email_thread) }

    it 'returns the user' do
      expect(email_thread.user).not_to be(nil)
    end
  end

  context '#destroy' do
    let(:emails) { create_email_thread_emails(email_threads) }

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

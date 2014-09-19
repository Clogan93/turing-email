require 'rails_helper'

describe SyncFailedEmail, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }

  context 'validations' do
    it 'should fail to save without an email_account and email_uid' do
      sync_failed_email = SyncFailedEmail.new
      expect(sync_failed_email.save).to be(false)

      sync_failed_email.email_account = email_account
      expect(sync_failed_email.save).to be(false)

      sync_failed_email.email_uid = '1'
      expect(sync_failed_email.save).to be(true)
    end
  end
  
  it 'should create a SyncFailedEmail' do
    expect(email_account.sync_failed_emails.count).to eq(0)
    
    SyncFailedEmail.create_retry(email_account, '1', result: nil, ex: nil)
    SyncFailedEmail.create_retry(email_account, '2', result: nil, ex: Exception.new)
    SyncFailedEmail.create_retry(email_account, '3', result: {}, ex: nil)
    
    expect(email_account.sync_failed_emails.count).to eq(3)
  end
  
  it 'should update the result and exception of a SyncFailedEmail' do
    expect(email_account.sync_failed_emails.count).to eq(0)
    
    SyncFailedEmail.create_retry(email_account, '1', result: nil, ex: nil)
    expect(email_account.sync_failed_emails.count).to eq(1)
    SyncFailedEmail.create_retry(email_account, '1', result: {}, ex: StandardError.new)
    expect(email_account.sync_failed_emails.count).to eq(1)
    
    sync_failed_email = SyncFailedEmail.find_by(:email_account => email_account, :email_uid => '1')
    expect(sync_failed_email.result).to eq({}.to_yaml)
    expect(sync_failed_email.exception).to eq(StandardError.new.to_yaml)

    expect(email_account.sync_failed_emails.count).to eq(1)
  end
end
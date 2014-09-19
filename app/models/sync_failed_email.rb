class SyncFailedEmail < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  
  validates_presence_of(:email_account, :email_uid)
  
  def SyncFailedEmail.create_retry(email_account, email_uid, result: nil, ex: nil)
    sync_failed_email = nil
    
    retry_block do
      sync_failed_email = SyncFailedEmail.find_or_create_by!(:email_account => email_account,
                                                             :email_uid => email_uid)
      sync_failed_email.result = result.to_yaml if result
      sync_failed_email.exception = ex.to_yaml if ex
      sync_failed_email.save!
    end
    
    return sync_failed_email
  end
end

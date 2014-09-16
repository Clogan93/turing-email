class SyncFailedEmail < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true
  
  validates_presence_of(:email_account, :uid)
  
  def SyncFailedEmail.create_retry(result: nil, ex: nil)
    retry_block do
      sync_failed_email = SyncFailedEmail.find_or_create_by!(:email_account => self,
                                                             :uid => result.request.parameters['id'])
      sync_failed_email.result = result.to_yaml if result
      sync_failed_email.exception = ex.to_yaml if ex
      sync_failed_email.save!
    end
  end
end

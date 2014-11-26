class EmailAttachment < ActiveRecord::Base
  belongs_to :email
  
  validates_presence_of(:uid, :email, :file_size)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }

  before_destroy {
    log_exception() do
      self.delay.s3_delete(self.s3_key) if !self.s3_key.blank?
    end
  }
end

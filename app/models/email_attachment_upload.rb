class EmailAttachmentUpload < ActiveRecord::Base
  belongs_to :user
  belongs_to :email

  validates_presence_of(:uid, :user, :s3_key)

  before_validation {
    self.uid = SecureRandom.uuid() if self.uid.nil?
    self.s3_key = s3_get_new_key() if self.s3_key.nil?
  }

  before_destroy {
    log_exception() do
      EmailAttachmentUpload.delay.s3_delete(self.s3_path()) if !self.s3_key.blank?
    end
  }
  
  def s3_path
    return nil if self.user.nil? || self.s3_key.nil?
    
    return "uploads/#{self.user.id}/#{self.s3_key}/${filename}"
  end
  
  def presigned_post
    return nil if self.user.nil? || self.s3_key.nil?
    
    s3_bucket = s3_get_bucket()
    return s3_bucket.presigned_post(key: self.s3_path(), success_action_status: 201)
  end
end

class EmailTracker < ActiveRecord::Base
  serialize :email_uids

  belongs_to :email_account, polymorphic: true
  
  has_many :email_tracker_recipients,
           :dependent => :destroy
  
  validates_presence_of(:email_account, :uid, :email_subject, :email_date)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

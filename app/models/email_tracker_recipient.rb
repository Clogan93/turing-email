class EmailTrackerRecipient < ActiveRecord::Base
  belongs_to :email_tracker
  belongs_to :email

  has_many :email_tracker_views,
           :dependent => :destroy

  validates_presence_of(:email_tracker, :email, :uid, :email_address)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

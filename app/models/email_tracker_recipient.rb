class EmailTrackerRecipient < ActiveRecord::Base
  belongs_to :email_tracker
  belongs_to :email

  has_many :email_tracker_views,
           :dependent => :destroy

  # TODO require :email after fix the SMTP send sync issue
  validates_presence_of(:email_tracker, :uid, :email_address)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

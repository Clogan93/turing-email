class EmailTrackerView < ActiveRecord::Base
  belongs_to :email_tracker_recipient

  validates_presence_of(:email_tracker_recipient, :uid, :ip_address)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

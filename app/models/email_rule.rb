class EmailRule < ActiveRecord::Base
  belongs_to :user

  validates_presence_of(:user, :uid, :destination_folder_name)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

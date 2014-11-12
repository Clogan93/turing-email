class Skin < ActiveRecord::Base
  validates_presence_of(:name)
  
  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

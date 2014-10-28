class App < ActiveRecord::Base
  belongs_to :user
  
  has_many :installed_apps,
           :dependent => :destroy

  enum :app_type => { :panel => 'panel' }
  
  validates_presence_of(:user, :uid, :name, :description, :app_type, :callback_url)

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end

class InstalledApp < ActiveRecord::Base
  belongs_to :installed_app_subclass, polymorphic: true, :dependent => :destroy
  
  belongs_to :user
  belongs_to :app

  validates_presence_of(:user, :app)
end

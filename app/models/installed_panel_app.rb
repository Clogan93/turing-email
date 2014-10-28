class InstalledPanelApp < ActiveRecord::Base
  enum :panel => { :right => 'right' }
  
  has_one :installed_app,
          :as => :installed_app_subclass

  validates_presence_of(:installed_app, :panel, :position)
end

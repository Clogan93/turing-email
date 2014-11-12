class UserConfiguration < ActiveRecord::Base
  belongs_to :user
  belongs_to :skin

  validates_presence_of(:user)

  enum :split_pane_mode => { :off => 'off', :horizontal => 'horizontal', :vertical => 'vertical' }
end

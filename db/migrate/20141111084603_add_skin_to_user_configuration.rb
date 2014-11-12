class AddSkinToUserConfiguration < ActiveRecord::Migration
  def change
    add_belongs_to :user_configurations, :skin
  end
end

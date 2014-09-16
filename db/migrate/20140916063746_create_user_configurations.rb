class CreateUserConfigurations < ActiveRecord::Migration
  def change
    create_table :user_configurations do |t|
      t.belongs_to :user

      t.boolean :genie_enabled, :default => true
      t.text :split_pane_mode, :default => 'off'

      t.timestamps
    end

    add_index :user_configurations, :user_id, :unique => true
  end
end

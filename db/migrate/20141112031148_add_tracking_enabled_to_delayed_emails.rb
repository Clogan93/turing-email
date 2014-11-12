class AddTrackingEnabledToDelayedEmails < ActiveRecord::Migration
  def change
    add_column :delayed_emails, :tracking_enabled, :boolean
  end
end

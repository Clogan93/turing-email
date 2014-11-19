class AddBounceBackToDelayedEmails < ActiveRecord::Migration
  def change
    add_column :delayed_emails, :bounce_back, :boolean, :default => false
    add_column :delayed_emails, :bounce_back_time, :datetime
    add_column :delayed_emails, :bounce_back_type, :text
  end
end

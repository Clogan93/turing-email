class AddBounceBackToEmails < ActiveRecord::Migration
  def change
    add_column :emails, :bounce_back, :boolean, :default => false
    add_column :emails, :bounce_back_time, :datetime
    add_column :emails, :bounce_back_type, :text
    add_column :emails, :bounce_back_job_id, :integer
  end
end

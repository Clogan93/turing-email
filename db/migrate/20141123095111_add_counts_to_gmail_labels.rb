class AddCountsToGmailLabels < ActiveRecord::Migration
  def change
    add_column :gmail_labels, :num_threads, :integer
    add_column :gmail_labels, :num_unread_threads, :integer
  end
end

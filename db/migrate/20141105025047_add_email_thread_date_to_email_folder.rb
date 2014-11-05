class AddEmailThreadDateToEmailFolder < ActiveRecord::Migration
  def change
    add_column :email_folder_mappings, :folder_email_thread_date, :datetime

    add_index :email_folder_mappings, [:folder_email_thread_date, :email_id],
              :name => 'index_email_folder_mappings_on_thread_date_and_email_id'
  end
end

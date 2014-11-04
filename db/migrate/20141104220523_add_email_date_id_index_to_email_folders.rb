class AddEmailDateIdIndexToEmailFolders < ActiveRecord::Migration
  def change
    add_index :email_folder_mappings, [:folder_email_date, :email_id]
  end
end

class AddEmailFieldsToEmailFolderMapping < ActiveRecord::Migration
  def change
    add_column :email_folder_mappings, :folder_email_date, :datetime
    add_column :email_folder_mappings, :folder_email_draft_id, :text
    add_belongs_to :email_folder_mappings, :email_thread, :index => true

    add_index :email_folder_mappings, :folder_email_date
    add_index :email_folder_mappings, :folder_email_draft_id
  end
end

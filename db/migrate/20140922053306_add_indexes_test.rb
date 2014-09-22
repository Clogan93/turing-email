class AddIndexesTest < ActiveRecord::Migration
  def change
    add_index :emails, [:date]
    add_index :emails, [:id], :where => 'NOT seen'
    add_index :emails, [:id, :date]
    add_index :email_folder_mappings, [:email_folder_id, :email_folder_type],
              :name => 'index_email_folder_mappings_on_email_folder'
  end
end

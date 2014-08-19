class CreateEmailFolderMappings < ActiveRecord::Migration
  def change
    create_table :email_folder_mappings do |t|
      t.belongs_to :email
      t.belongs_to :email_folder, polymorphic: true

      t.timestamps
    end

    add_index :email_folder_mappings, [:email_id, :email_folder_id], :unique => true
  end
end

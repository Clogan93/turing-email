class CreateImapFolders < ActiveRecord::Migration
  def change
    create_table :imap_folders do |t|
      t.belongs_to :email_account, polymorphic: true

      t.text :name

      t.timestamps
    end

    add_index :imap_folders, [:email_account_id, :name], unique: true
    add_index :imap_folders, :email_account_id
  end
end

class CreateGmailAccounts < ActiveRecord::Migration
  def change
    create_table :gmail_accounts do |t|
      t.belongs_to :user

      t.text :google_id
      t.text :email
      t.boolean :verified_email

      t.text :last_history_id_synced

      t.timestamps
    end

    add_index :gmail_accounts, [:user_id, :google_id], unique: true
    add_index :gmail_accounts, [:user_id, :email], unique: true
    add_index :gmail_accounts, :email
  end
end

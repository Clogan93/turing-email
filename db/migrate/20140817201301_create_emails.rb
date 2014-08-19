class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.belongs_to :user
      t.belongs_to :email_account, polymorphic: true

      t.text :uid
      t.text :message_id
      t.text :thread_id
      t.text :list_id

      t.boolean :seen, :default => false
      t.text :snippet

      t.datetime :date

      t.text :from_name
      t.text :from_address

      t.text :tos
      t.text :ccs
      t.text :bccs
      t.text :subject

      t.text :html_part
      t.text :text_part
      t.text :body_text

      t.timestamps
    end

    add_index :emails, [:user_id, :email_account_id, :message_id], unique: true
    add_index :emails, [:user_id, :email_account_id, :uid], unique: true
    add_index :emails, :uid
    add_index :emails, :message_id
    add_index :emails, :thread_id
  end
end

class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.belongs_to :email_account, polymorphic: true
      t.belongs_to :email_thread

      t.boolean :auto_filed, :default => false
      t.boolean :auto_filed_reported, :default => false
      t.belongs_to :auto_filed_folder, polymorphic: true

      t.text :uid
      t.text :message_id
      t.text :list_id

      t.boolean :seen, :default => false
      t.text :snippet

      t.datetime :date

      t.text :from_name, :from_address
      t.text :sender_name, :sender_address
      t.text :reply_to_name, :reply_to_address

      t.text :tos, :ccs, :bccs
      t.text :subject

      t.text :html_part
      t.text :text_part
      t.text :body_text

      t.boolean :has_calendar_attachment, :default => false

      t.timestamps
    end

    add_index :emails, [:email_account_type, :email_account_id, :uid], unique: true
    add_index :emails, [:email_account_type, :email_account_id]
    add_index :emails, :uid
    add_index :emails, :message_id
    add_index :emails, :email_thread_id
  end
end

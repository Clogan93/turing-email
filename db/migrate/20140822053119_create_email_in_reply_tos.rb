class CreateEmailInReplyTos < ActiveRecord::Migration
  def change
    create_table :email_in_reply_tos do |t|
      t.belongs_to :email_account, polymorphic: true
      t.belongs_to :email

      t.text :in_reply_to_message_id

      t.timestamps
    end

    add_index :email_in_reply_tos, [:email_account_id, :email_account_type],
              :name => 'index_email_in_reply_tos_on_email_account'
    add_index :email_in_reply_tos, :email_id
    add_index :email_in_reply_tos, [:email_id, :in_reply_to_message_id], :unique => true
    add_index :email_in_reply_tos, [:email_account_id, :email_account_type, :in_reply_to_message_id],
              :name => 'index_email_in_reply_tos_ea_and_irtm_id'
  end
end

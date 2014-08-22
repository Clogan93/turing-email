class CreateEmailReferences < ActiveRecord::Migration
  def change
    create_table :email_references do |t|
      t.belongs_to :email_account, polymorphic: true
      t.belongs_to :email

      t.text :references_message_id

      t.timestamps
    end

    add_index :email_references, :email_account_id
    add_index :email_references, :email_id
    add_index :email_references, [:email_id, :references_message_id], unique: true
    add_index :email_references, [:email_account_id, :references_message_id],
              name: 'index_email_references_ea_id_and_rm_id'
  end
end

class CreateEmailReferences < ActiveRecord::Migration
  def change
    create_table :email_references do |t|
      t.belongs_to :email

      t.text :references_message_id

      t.timestamps
    end

    add_index :email_references, :email_id
    add_index :email_references, [:email_id, :references_message_id], unique: true
  end
end

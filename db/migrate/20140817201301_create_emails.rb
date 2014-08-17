class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.belongs_to :user

      t.text :message_id

      t.text :from_name
      t.text :from_address

      t.text :tos
      t.text :ccs
      t.text :subject

      t.text :html_part
      t.text :text_part
      t.text :body_text

      t.timestamps
    end

    add_index :emails, :message_id, unique: true
  end
end

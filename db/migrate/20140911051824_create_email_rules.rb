class CreateEmailRules < ActiveRecord::Migration
  def change
    create_table :email_rules do |t|
      t.belongs_to :user

      t.text :from_address
      t.text :to_address
      t.text :subject
      t.text :list_id
      
      t.text :destination_folder

      t.timestamps
    end

    add_index :email_rules, [:from_address, :to_address, :subject, :list_id, :destination_folder],
              :unique => true, :name => 'index_email_rules_on_everything'
  end
end

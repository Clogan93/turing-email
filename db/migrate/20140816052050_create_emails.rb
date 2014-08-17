class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :from_address
      t.string :to_address
      t.string :subject
      t.text :body
      t.boolean :read

      t.timestamps
    end
  end
end

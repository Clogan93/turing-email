class CreateEmailThreads < ActiveRecord::Migration
  def change
    create_table :email_threads do |t|
      t.belongs_to :email_account, polymorphic: true
      t.text :uid

      t.timestamps
    end

    add_index :email_threads, [:user_id, :email_account_id, :uid], unique: true
    add_index :email_threads, :uid
  end
end

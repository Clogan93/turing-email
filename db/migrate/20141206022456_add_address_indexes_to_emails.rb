class AddAddressIndexesToEmails < ActiveRecord::Migration
  def change
    add_index :emails, :tos
    add_index :emails, :ccs
    add_index :emails, :bccs
    
    add_index :emails, :from_address
    add_index :emails, :sender_address
    add_index :emails, :reply_to_address
  end
end

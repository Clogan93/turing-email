class CreateUserGoogleAuthTokens < ActiveRecord::Migration
  def change
    create_table :user_google_auth_tokens do |t|
      t.belongs_to :user

      t.text :access_token
      t.integer :expires_in
      t.integer :issued_at
      t.text :refresh_token

      t.datetime :expires_at

      t.text :google_id
      t.text :email
      t.boolean :verified_email

      t.timestamps
    end

    add_index :user_google_auth_tokens, [:user_id, :email], unique: true
  end
end

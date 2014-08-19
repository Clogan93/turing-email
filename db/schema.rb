# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140819000500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "email_folder_mappings", force: true do |t|
    t.integer  "email_id"
    t.integer  "email_folder_id"
    t.string   "email_folder_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_folder_mappings", ["email_id", "email_folder_id"], name: "index_email_folder_mappings_on_email_id_and_email_folder_id", unique: true, using: :btree

  create_table "emails", force: true do |t|
    t.integer  "user_id"
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "uid"
    t.text     "message_id"
    t.text     "thread_id"
    t.boolean  "seen",               default: false
    t.text     "snippet"
    t.datetime "date"
    t.text     "from_name"
    t.text     "from_address"
    t.text     "tos"
    t.text     "ccs"
    t.text     "bccs"
    t.text     "subject"
    t.text     "html_part"
    t.text     "text_part"
    t.text     "body_text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emails", ["message_id"], name: "index_emails_on_message_id", using: :btree
  add_index "emails", ["thread_id"], name: "index_emails_on_thread_id", using: :btree
  add_index "emails", ["uid"], name: "index_emails_on_uid", using: :btree
  add_index "emails", ["user_id", "email_account_id", "message_id"], name: "index_emails_on_user_id_and_email_account_id_and_message_id", unique: true, using: :btree
  add_index "emails", ["user_id", "email_account_id", "uid"], name: "index_emails_on_user_id_and_email_account_id_and_uid", unique: true, using: :btree

  create_table "gmail_accounts", force: true do |t|
    t.integer  "user_id"
    t.text     "google_id"
    t.text     "email"
    t.boolean  "verified_email"
    t.text     "last_history_id_synced"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gmail_accounts", ["email"], name: "index_gmail_accounts_on_email", using: :btree
  add_index "gmail_accounts", ["user_id", "email"], name: "index_gmail_accounts_on_user_id_and_email", unique: true, using: :btree
  add_index "gmail_accounts", ["user_id", "google_id"], name: "index_gmail_accounts_on_user_id_and_google_id", unique: true, using: :btree

  create_table "gmail_labels", force: true do |t|
    t.integer  "gmail_account_id"
    t.text     "label_id"
    t.text     "name"
    t.text     "message_list_visibility"
    t.text     "label_list_visibility"
    t.text     "label_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gmail_labels", ["gmail_account_id", "label_id"], name: "index_gmail_labels_on_gmail_account_id_and_label_id", unique: true, using: :btree
  add_index "gmail_labels", ["gmail_account_id"], name: "index_gmail_labels_on_gmail_account_id", using: :btree

  create_table "google_o_auth2_tokens", force: true do |t|
    t.integer  "google_api_id"
    t.string   "google_api_type"
    t.text     "access_token"
    t.integer  "expires_in"
    t.integer  "issued_at"
    t.text     "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imap_folders", force: true do |t|
    t.integer  "email_account_id"
    t.string   "email_account_type"
    t.text     "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "imap_folders", ["email_account_id", "name"], name: "index_imap_folders_on_email_account_id_and_name", unique: true, using: :btree
  add_index "imap_folders", ["email_account_id"], name: "index_imap_folders_on_email_account_id", using: :btree

  create_table "user_auth_keys", force: true do |t|
    t.integer  "user_id"
    t.text     "encrypted_auth_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_auth_keys", ["encrypted_auth_key"], name: "index_user_auth_keys_on_encrypted_auth_key", using: :btree
  add_index "user_auth_keys", ["user_id"], name: "index_user_auth_keys_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.boolean  "admin"
    t.text     "email"
    t.text     "password_digest"
    t.integer  "login_attempt_count", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end

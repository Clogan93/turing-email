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

ActiveRecord::Schema.define(version: 20140816053514) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "user_auth_keys", force: true do |t|
    t.integer  "user_id"
    t.text     "encrypted_auth_key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_auth_keys", ["encrypted_auth_key"], name: "index_user_auth_keys_on_encrypted_auth_key", using: :btree
  add_index "user_auth_keys", ["user_id"], name: "index_user_auth_keys_on_user_id", using: :btree

  create_table "user_google_auth_tokens", force: true do |t|
    t.integer  "user_id"
    t.text     "access_token"
    t.text     "token_type"
    t.integer  "expires_in"
    t.integer  "issued_at"
    t.text     "refresh_token"
    t.datetime "expires_at"
    t.text     "google_id"
    t.text     "email"
    t.boolean  "verified_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_google_auth_tokens", ["user_id", "email"], name: "index_user_google_auth_tokens_on_user_id_and_email", unique: true, using: :btree

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

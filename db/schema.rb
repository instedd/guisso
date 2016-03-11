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

ActiveRecord::Schema.define(version: 20160311190127) do

  create_table "access_tokens", force: true do |t|
    t.integer  "client_id"
    t.integer  "resource_id"
    t.string   "token"
    t.string   "secret"
    t.string   "algorithm"
    t.integer  "refresh_token_id"
    t.datetime "expires_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "applications", force: true do |t|
    t.string   "identifier"
    t.string   "secret"
    t.string   "name"
    t.string   "hostname"
    t.boolean  "trusted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "authorization_codes", force: true do |t|
    t.integer  "user_id"
    t.integer  "client_id"
    t.integer  "resource_id"
    t.string   "token"
    t.string   "redirect_uri"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "extra_passwords", force: true do |t|
    t.integer  "user_id"
    t.string   "encrypted_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pepper"
  end

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instedd_telemetry_counters", force: true do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.integer "count",               default: 0
    t.string  "key_attributes_hash"
  end

  add_index "instedd_telemetry_counters", ["bucket", "key_attributes_hash", "period_id"], name: "instedd_telemetry_counters_unique_fields", unique: true, using: :btree

  create_table "instedd_telemetry_periods", force: true do |t|
    t.datetime "beginning"
    t.datetime "end"
    t.datetime "stats_sent_at"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "lock_owner"
    t.datetime "lock_expiration"
  end

  create_table "instedd_telemetry_set_occurrences", force: true do |t|
    t.integer "period_id"
    t.string  "bucket"
    t.text    "key_attributes"
    t.string  "element"
    t.string  "key_attributes_hash"
  end

  add_index "instedd_telemetry_set_occurrences", ["bucket", "key_attributes_hash", "element", "period_id"], name: "instedd_telemetry_set_occurrences_unique_fields", unique: true, using: :btree

  create_table "instedd_telemetry_settings", force: true do |t|
    t.string "key"
    t.string "value"
  end

  add_index "instedd_telemetry_settings", ["key"], name: "index_instedd_telemetry_settings_on_key", unique: true, using: :btree

  create_table "instedd_telemetry_timespans", force: true do |t|
    t.string   "bucket"
    t.text     "key_attributes"
    t.datetime "since"
    t.datetime "until"
    t.string   "key_attributes_hash"
  end

  add_index "instedd_telemetry_timespans", ["bucket", "key_attributes_hash"], name: "instedd_telemetry_timespans_unique_fields", unique: true, using: :btree

  create_table "refresh_tokens", force: true do |t|
    t.integer  "client_id"
    t.integer  "resource_id"
    t.integer  "access_token_id"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "trusted_roots", force: true do |t|
    t.integer  "user_id"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trusted_roots", ["user_id"], name: "index_trusted_roots_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end

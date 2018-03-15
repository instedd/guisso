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

ActiveRecord::Schema.define(version: 20180315034653) do

  create_table "access_tokens", force: :cascade do |t|
    t.integer  "client_id",        limit: 4
    t.integer  "resource_id",      limit: 4
    t.string   "token",            limit: 255
    t.string   "secret",           limit: 255
    t.string   "algorithm",        limit: 255
    t.integer  "refresh_token_id", limit: 4
    t.datetime "expires_at"
    t.integer  "user_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type",             limit: 255
    t.string   "scope",            limit: 255
  end

  create_table "applications", force: :cascade do |t|
    t.string   "identifier",    limit: 255
    t.string   "secret",        limit: 255
    t.string   "name",          limit: 255
    t.string   "hostname",      limit: 255
    t.boolean  "trusted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",       limit: 4
    t.text     "redirect_uris", limit: 65535
  end

  create_table "authorization_codes", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.integer  "client_id",    limit: 4
    t.integer  "resource_id",  limit: 4
    t.string   "token",        limit: 255
    t.string   "redirect_uri", limit: 255
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scope",        limit: 255
  end

  create_table "authorizations", force: :cascade do |t|
    t.integer "client_id",   limit: 4
    t.integer "resource_id", limit: 4
    t.integer "user_id",     limit: 4
    t.string  "scope",       limit: 255
  end

  add_index "authorizations", ["user_id", "client_id", "resource_id"], name: "index_authorizations_on_user_id_and_client_id_and_resource_id", unique: true, using: :btree

  create_table "extra_passwords", force: :cascade do |t|
    t.integer  "user_id",            limit: 4
    t.string   "encrypted_password", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pepper",             limit: 255
  end

  create_table "identities", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "provider",   limit: 255
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "instedd_telemetry_counters", force: :cascade do |t|
    t.integer "period_id",           limit: 4
    t.string  "bucket",              limit: 255
    t.text    "key_attributes",      limit: 65535
    t.integer "count",               limit: 4,     default: 0
    t.string  "key_attributes_hash", limit: 255
  end

  add_index "instedd_telemetry_counters", ["bucket", "key_attributes_hash", "period_id"], name: "instedd_telemetry_counters_unique_fields", unique: true, using: :btree

  create_table "instedd_telemetry_periods", force: :cascade do |t|
    t.datetime "beginning"
    t.datetime "end"
    t.datetime "stats_sent_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "lock_owner",      limit: 255
    t.datetime "lock_expiration"
  end

  create_table "instedd_telemetry_set_occurrences", force: :cascade do |t|
    t.integer "period_id",           limit: 4
    t.string  "bucket",              limit: 255
    t.text    "key_attributes",      limit: 65535
    t.string  "element",             limit: 255
    t.string  "key_attributes_hash", limit: 255
  end

  add_index "instedd_telemetry_set_occurrences", ["bucket", "key_attributes_hash", "element", "period_id"], name: "instedd_telemetry_set_occurrences_unique_fields", unique: true, using: :btree

  create_table "instedd_telemetry_settings", force: :cascade do |t|
    t.string "key",   limit: 255
    t.string "value", limit: 255
  end

  add_index "instedd_telemetry_settings", ["key"], name: "index_instedd_telemetry_settings_on_key", unique: true, using: :btree

  create_table "instedd_telemetry_timespans", force: :cascade do |t|
    t.string   "bucket",              limit: 255
    t.text     "key_attributes",      limit: 65535
    t.datetime "since"
    t.datetime "until"
    t.string   "key_attributes_hash", limit: 255
  end

  add_index "instedd_telemetry_timespans", ["bucket", "key_attributes_hash"], name: "instedd_telemetry_timespans_unique_fields", unique: true, using: :btree

  create_table "refresh_tokens", force: :cascade do |t|
    t.integer  "client_id",       limit: 4
    t.integer  "resource_id",     limit: 4
    t.integer  "access_token_id", limit: 4
    t.string   "token",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "trusted_roots", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "url",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "trusted_roots", ["user_id"], name: "index_trusted_roots_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                   limit: 255
    t.string   "role",                   limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end

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

ActiveRecord::Schema.define(version: 20160813102940) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string   "name"
    t.integer  "currency_id"
    t.integer  "family_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "interest_rate"
    t.integer  "position"
    t.datetime "deleted_at"
    t.integer  "child_id"
    t.integer  "split_percentage", default: 0
    t.index ["child_id"], name: "index_accounts_on_child_id", using: :btree
    t.index ["currency_id"], name: "index_accounts_on_currency_id", using: :btree
    t.index ["family_id"], name: "index_accounts_on_family_id", using: :btree
  end

  create_table "children", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.integer  "family_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "email_enabled",           default: true
    t.text     "account_update_schedule"
    t.boolean  "split_earnings",          default: false
    t.index ["family_id"], name: "index_children_on_family_id", using: :btree
  end

  create_table "chores", force: :cascade do |t|
    t.string   "name"
    t.datetime "due_date"
    t.datetime "paid_on"
    t.text     "description"
    t.integer  "value"
    t.integer  "child_id"
    t.integer  "family_id"
    t.integer  "parent_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "deleted_at"
    t.string   "status",      default: "open"
    t.boolean  "recurring",   default: false
    t.index ["child_id"], name: "index_chores_on_child_id", using: :btree
    t.index ["family_id"], name: "index_chores_on_family_id", using: :btree
    t.index ["parent_id"], name: "index_chores_on_parent_id", using: :btree
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name"
    t.string   "icon"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "zero_decimal", default: false
    t.boolean  "monetary",     default: false
  end

  create_table "families", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "amount"
    t.integer  "account_id"
    t.string   "description"
    t.string   "payee"
    t.string   "payor"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "transaction_type"
    t.index ["account_id"], name: "index_transactions_on_account_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
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
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.json     "tokens"
    t.integer  "family_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "child_id"
    t.index ["child_id"], name: "index_users_on_child_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "accounts", "children"
  add_foreign_key "accounts", "currencies"
  add_foreign_key "accounts", "families"
  add_foreign_key "children", "families"
  add_foreign_key "chores", "children"
  add_foreign_key "chores", "families"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "users", "children"
end

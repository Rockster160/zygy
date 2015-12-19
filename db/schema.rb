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

ActiveRecord::Schema.define(version: 20151219193449) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: true do |t|
    t.string   "name"
    t.string   "game_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchase_trackers", force: true do |t|
    t.integer  "at_1",         default: 0
    t.integer  "at_2",         default: 0
    t.integer  "at_3",         default: 0
    t.integer  "at_4",         default: 0
    t.integer  "at_5",         default: 0
    t.integer  "at_6",         default: 0
    t.integer  "at_7",         default: 0
    t.integer  "at_8",         default: 0
    t.integer  "at_9",         default: 0
    t.integer  "at_10",        default: 0
    t.integer  "at_11",        default: 0
    t.integer  "at_12",        default: 0
    t.integer  "at_13",        default: 0
    t.integer  "at_14",        default: 0
    t.integer  "at_15",        default: 0
    t.integer  "cumulative",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_game_id"
    t.integer  "game_id"
    t.integer  "user_id"
  end

  create_table "purchases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",       default: 0
    t.integer  "user_game_id"
  end

  create_table "security_keys", force: true do |t|
    t.string   "authorization_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_game_id"
  end

  create_table "user_game_scores", force: true do |t|
    t.integer  "score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.integer  "level"
    t.integer  "user_game_id"
  end

  create_table "user_games", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_games", ["game_id"], name: "index_user_games_on_game_id", using: :btree
  add_index "user_games", ["user_id"], name: "index_user_games_on_user_id", using: :btree

  create_table "user_score_trackers", force: true do |t|
    t.integer  "at_1",          default: 0
    t.integer  "at_2",          default: 0
    t.integer  "at_3",          default: 0
    t.integer  "at_4",          default: 0
    t.integer  "at_5",          default: 0
    t.integer  "at_6",          default: 0
    t.integer  "at_7",          default: 0
    t.integer  "at_8",          default: 0
    t.integer  "at_9",          default: 0
    t.integer  "at_10",         default: 0
    t.integer  "at_11",         default: 0
    t.integer  "at_12",         default: 0
    t.integer  "at_13",         default: 0
    t.integer  "at_14",         default: 0
    t.integer  "at_15",         default: 0
    t.integer  "all_time_high", default: 0
    t.integer  "cumulative",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_game_id"
    t.integer  "game_id"
    t.integer  "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "solution_number"
    t.integer  "upline_id"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

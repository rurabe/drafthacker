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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120808043851) do

  create_table "drafts", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.datetime "start_time"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "drafts", ["user_id"], :name => "index_drafts_on_user_id"

  create_table "leagues", :force => true do |t|
    t.integer  "draft_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.integer  "regular_season_periods"
    t.integer  "playoff_periods"
    t.string   "season_status"
    t.string   "name"
    t.string   "draft_type"
    t.integer  "num_divisions"
    t.integer  "uses_keepers"
    t.integer  "num_teams"
    t.string   "commish_type"
    t.boolean  "use_robot"
    t.time     "time"
    t.date     "date"
    t.string   "order_type"
    t.string   "order_source"
    t.integer  "auction_supplemental_rounds"
    t.integer  "timer_start"
    t.boolean  "pick_email"
    t.string   "draft_event_type"
    t.string   "draft_schedule"
    t.integer  "rounds"
    t.integer  "time_limit"
    t.integer  "timer_end"
  end

  add_index "leagues", ["draft_id"], :name => "index_leagues_on_draft_id"

  create_table "picks", :force => true do |t|
    t.integer  "player_id"
    t.integer  "team_id"
    t.integer  "round_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "picks", ["player_id"], :name => "index_picks_on_player_id"
  add_index "picks", ["round_id"], :name => "index_picks_on_round_id"
  add_index "picks", ["team_id"], :name => "index_picks_on_team_id"

  create_table "players", :force => true do |t|
    t.string   "name"
    t.integer  "team_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "type"
  end

  add_index "players", ["team_id"], :name => "index_players_on_team_id"

  create_table "rounds", :force => true do |t|
    t.integer  "draft_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "rounds", ["draft_id"], :name => "index_rounds_on_draft_id"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "league_id"
  end

  add_index "teams", ["user_id"], :name => "index_teams_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end

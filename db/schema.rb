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

ActiveRecord::Schema.define(:version => 20120814101351) do

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
    t.string   "draft_state"
    t.integer  "timestamp"
  end

  add_index "leagues", ["draft_id"], :name => "index_leagues_on_draft_id"

  create_table "owners", :force => true do |t|
    t.boolean  "commissioner"
    t.string   "name"
    t.string   "cbs_hex_id"
    t.integer  "team_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "picks", :force => true do |t|
    t.integer  "player_id"
    t.integer  "team_id"
    t.integer  "round_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "number"
    t.integer  "league_team_id"
    t.integer  "draft_id"
  end

  add_index "picks", ["player_id"], :name => "index_picks_on_player_id"
  add_index "picks", ["round_id"], :name => "index_picks_on_round_id"
  add_index "picks", ["team_id"], :name => "index_picks_on_team_id"

  create_table "players", :force => true do |t|
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "type"
    t.integer  "cbs_id"
    t.string   "first_name"
    t.string   "full_name"
    t.string   "last_name"
    t.string   "on_waivers"
    t.string   "position"
    t.string   "pro_status"
    t.string   "pro_team"
    t.string   "bye_week"
    t.string   "is_locked"
    t.string   "opponent"
    t.integer  "slot_id"
    t.decimal  "pct"
    t.decimal  "change"
    t.decimal  "avg"
    t.integer  "high"
    t.integer  "low"
    t.integer  "rank"
    t.string   "icons_injury"
    t.string   "icons_headline"
    t.integer  "av_cbs"
    t.integer  "av_cbs_ppr"
    t.integer  "av_dave_richard"
    t.integer  "av_dave_richard_ppr"
    t.integer  "av_jamey_eisenberg"
    t.integer  "av_jamey_eisenberg_ppr"
    t.integer  "av_nathan_zegura"
  end

  add_index "players", ["slot_id"], :name => "index_players_on_slot_id"

  create_table "rounds", :force => true do |t|
    t.integer  "draft_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "number"
  end

  add_index "rounds", ["draft_id"], :name => "index_rounds_on_draft_id"

  create_table "slots", :force => true do |t|
    t.integer  "team_id"
    t.integer  "player_id"
    t.string   "eligible_positions"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "slots", ["player_id"], :name => "index_slots_on_player_id"
  add_index "slots", ["team_id"], :name => "index_slots_on_team_id"

  create_table "teams", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "league_id"
    t.string   "long_abbr"
    t.boolean  "logged_in_team"
    t.string   "short_name"
    t.string   "abbr"
    t.string   "owners"
    t.integer  "league_team_id"
    t.text     "logo"
  end

  add_index "teams", ["league_id"], :name => "index_teams_on_league_id"
  add_index "teams", ["league_team_id"], :name => "index_teams_on_league_team_id"
  add_index "teams", ["user_id"], :name => "index_teams_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "cbs_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

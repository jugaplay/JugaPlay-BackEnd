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

ActiveRecord::Schema.define(version: 20161016134351) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "channels", force: :cascade do |t|
    t.integer  "user_id",                   null: false
    t.boolean  "mail",       default: true, null: false
    t.boolean  "sms",        default: true, null: false
    t.boolean  "whatsapp",   default: true, null: false
    t.boolean  "push",       default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "channels", ["user_id"], name: "index_channels_on_user_id", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "sender_name"
    t.string   "sender_email"
    t.text     "content",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_factory_players_mappings", force: :cascade do |t|
    t.integer  "player_id"
    t.integer  "data_factory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "data_factory_players_mappings", ["data_factory_id"], name: "index_data_factory_players_mappings_on_data_factory_id", unique: true, using: :btree
  add_index "data_factory_players_mappings", ["player_id", "data_factory_id"], name: "index_data_factory_players_mappings_player_df_id", unique: true, using: :btree
  add_index "data_factory_players_mappings", ["player_id"], name: "index_data_factory_players_mappings_on_player_id", unique: true, using: :btree

  create_table "directors", force: :cascade do |t|
    t.string   "first_name",  null: false
    t.string   "last_name",   null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "directors", ["first_name"], name: "index_directors_on_first_name", using: :btree
  add_index "directors", ["last_name"], name: "index_directors_on_last_name", using: :btree

  create_table "explanations", force: :cascade do |t|
    t.string   "name"
    t.text     "detail"
    t.boolean  "active",     default: true, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "explanations", ["name"], name: "index_explanations_on_name", unique: true, using: :btree

  create_table "explanations_users", force: :cascade do |t|
    t.integer  "user_id",        null: false
    t.integer  "explanation_id", null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "explanations_users", ["user_id", "explanation_id"], name: "index_explanations_users_on_user_id_and_explanation_id", unique: true, using: :btree

  create_table "invitation_statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "invitation_statuses", ["name"], name: "index_invitation_statuses_on_name", unique: true, using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "won_coins"
    t.inet     "guest_ip"
    t.string   "detail"
    t.integer  "invitation_status_id", null: false
    t.integer  "request_id",           null: false
    t.integer  "guest_user_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "matches", force: :cascade do |t|
    t.string   "title",           null: false
    t.integer  "local_team_id",   null: false
    t.integer  "visitor_team_id", null: false
    t.datetime "datetime",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id",   null: false
  end

  add_index "matches", ["local_team_id", "visitor_team_id", "datetime"], name: "index_matches_on_local_team_id_and_visitor_team_id_and_datetime", unique: true, using: :btree

  create_table "matches_tables", force: :cascade do |t|
    t.integer  "match_id"
    t.integer  "table_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matches_tables", ["match_id"], name: "index_matches_tables_on_match_id", using: :btree
  add_index "matches_tables", ["table_id"], name: "index_matches_tables_on_table_id", using: :btree

  create_table "notification_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "notification_types", ["name"], name: "index_notification_types_on_name", unique: true, using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "notification_type_id"
    t.string   "title",                                null: false
    t.string   "image"
    t.text     "text"
    t.text     "action"
    t.boolean  "read",                 default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "notifications", ["notification_type_id"], name: "index_notifications_on_notification_type_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "player_stats", force: :cascade do |t|
    t.integer  "player_id",                             null: false
    t.integer  "match_id",                              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "shots",                   default: 0,   null: false
    t.integer  "shots_on_goal",           default: 0,   null: false
    t.integer  "shots_to_the_post",       default: 0,   null: false
    t.integer  "shots_outside",           default: 0,   null: false
    t.integer  "scored_goals",            default: 0,   null: false
    t.integer  "goalkeeper_scored_goals", default: 0,   null: false
    t.integer  "defender_scored_goals",   default: 0,   null: false
    t.integer  "free_kick_goal",          default: 0,   null: false
    t.integer  "right_passes",            default: 0,   null: false
    t.integer  "recoveries",              default: 0,   null: false
    t.integer  "assists",                 default: 0,   null: false
    t.integer  "undefeated_defense",      default: 0,   null: false
    t.integer  "saves",                   default: 0,   null: false
    t.integer  "saved_penalties",         default: 0,   null: false
    t.integer  "missed_saves",            default: 0,   null: false
    t.integer  "undefeated_goal",         default: 0,   null: false
    t.integer  "red_cards",               default: 0,   null: false
    t.integer  "yellow_cards",            default: 0,   null: false
    t.integer  "offside",                 default: 0,   null: false
    t.integer  "faults",                  default: 0,   null: false
    t.integer  "missed_penalties",        default: 0,   null: false
    t.integer  "winner_team",             default: 0,   null: false
    t.float    "wrong_passes",            default: 0.0, null: false
  end

  add_index "player_stats", ["player_id", "match_id"], name: "index_player_stats_on_player_id_and_match_id", unique: true, using: :btree

  create_table "players", force: :cascade do |t|
    t.string  "first_name",               null: false
    t.string  "last_name",                null: false
    t.string  "position",                 null: false
    t.text    "description", default: "", null: false
    t.date    "birthday",                 null: false
    t.string  "nationality",              null: false
    t.float   "weight",                   null: false
    t.float   "height",                   null: false
    t.integer "team_id"
  end

  add_index "players", ["first_name", "last_name", "team_id", "position"], name: "index_players_first_last_team_position", unique: true, using: :btree
  add_index "players", ["first_name"], name: "index_players_on_first_name", using: :btree
  add_index "players", ["last_name"], name: "index_players_on_last_name", using: :btree

  create_table "players_plays", force: :cascade do |t|
    t.integer  "play_id",    null: false
    t.integer  "player_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "players_plays", ["play_id", "player_id"], name: "index_players_plays_on_play_id_and_player_id", unique: true, using: :btree
  add_index "players_plays", ["play_id"], name: "index_players_plays_on_play_id", using: :btree

  create_table "plays", force: :cascade do |t|
    t.integer  "user_id",                null: false
    t.integer  "table_id",               null: false
    t.float    "points"
    t.float    "coins"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bet_coins",  default: 0, null: false
  end

  add_index "plays", ["table_id"], name: "index_plays_on_table_id", using: :btree
  add_index "plays", ["user_id", "table_id"], name: "index_plays_on_user_id_and_table_id", unique: true, using: :btree
  add_index "plays", ["user_id"], name: "index_plays_on_user_id", using: :btree

  create_table "rankings", force: :cascade do |t|
    t.integer  "tournament_id",               null: false
    t.integer  "user_id",                     null: false
    t.float    "points",        default: 0.0, null: false
    t.integer  "position",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rankings", ["position"], name: "index_rankings_on_position", using: :btree
  add_index "rankings", ["tournament_id", "position"], name: "index_rankings_on_tournament_id_and_position", unique: true, using: :btree
  add_index "rankings", ["tournament_id", "user_id"], name: "index_rankings_on_tournament_id_and_user_id", unique: true, using: :btree
  add_index "rankings", ["tournament_id"], name: "index_rankings_on_tournament_id", using: :btree
  add_index "rankings", ["user_id"], name: "index_rankings_on_user_id", using: :btree

  create_table "request_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "request_types", ["name"], name: "index_request_types_on_name", unique: true, using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "request_type_id", null: false
    t.integer  "host_user_id",    null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "requests", ["host_user_id"], name: "index_requests_on_host_user_id", using: :btree
  add_index "requests", ["request_type_id"], name: "index_requests_on_request_type_id", using: :btree

  create_table "sent_mails", force: :cascade do |t|
    t.string   "from"
    t.string   "to"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "t_deposits", force: :cascade do |t|
    t.integer  "coins"
    t.integer  "user_id"
    t.string   "detail"
    t.string   "transaction_id"
    t.float    "price"
    t.string   "operator"
    t.string   "deposit_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "country",         null: false
    t.string   "currency",        null: false
    t.string   "payment_service", null: false
  end

  add_index "t_deposits", ["user_id"], name: "index_t_deposits_on_user_id", using: :btree

  create_table "t_entry_fees", force: :cascade do |t|
    t.integer  "coins"
    t.integer  "user_id"
    t.string   "detail"
    t.integer  "tournament_id"
    t.integer  "table_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "t_entry_fees", ["table_id"], name: "index_t_entry_fees_on_table_id", using: :btree
  add_index "t_entry_fees", ["tournament_id"], name: "index_t_entry_fees_on_tournament_id", using: :btree
  add_index "t_entry_fees", ["user_id"], name: "index_t_entry_fees_on_user_id", using: :btree

  create_table "t_promotions", force: :cascade do |t|
    t.integer  "coins"
    t.string   "detail"
    t.string   "promotion_type"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "t_promotions", ["user_id"], name: "index_t_promotions_on_user_id", using: :btree

  create_table "table_rules", force: :cascade do |t|
    t.integer  "table_id",                                null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "shots",                   default: 1.0,   null: false
    t.float    "shots_on_goal",           default: 1.0,   null: false
    t.float    "shots_to_the_post",       default: 1.5,   null: false
    t.float    "shots_outside",           default: 0.0,   null: false
    t.float    "scored_goals",            default: 20.0,  null: false
    t.float    "goalkeeper_scored_goals", default: 27.0,  null: false
    t.float    "defender_scored_goals",   default: 25.0,  null: false
    t.float    "free_kick_goal",          default: 2.0,   null: false
    t.float    "right_passes",            default: 0.5,   null: false
    t.float    "recoveries",              default: 3.0,   null: false
    t.float    "assists",                 default: 6.0,   null: false
    t.float    "undefeated_defense",      default: 3.0,   null: false
    t.float    "saves",                   default: 2.5,   null: false
    t.float    "saved_penalties",         default: 10.0,  null: false
    t.float    "missed_saves",            default: -2.0,  null: false
    t.float    "undefeated_goal",         default: 5.0,   null: false
    t.float    "red_cards",               default: -10.0, null: false
    t.float    "yellow_cards",            default: -2.0,  null: false
    t.float    "offside",                 default: -1.0,  null: false
    t.float    "faults",                  default: -0.5,  null: false
    t.float    "missed_penalties",        default: -5.0,  null: false
    t.float    "winner_team",             default: 2.0,   null: false
    t.float    "wrong_passes",            default: -0.5,  null: false
  end

  add_index "table_rules", ["table_id"], name: "index_table_rules_on_table_id", unique: true, using: :btree

  create_table "table_winners", force: :cascade do |t|
    t.integer  "table_id",   null: false
    t.integer  "user_id",    null: false
    t.integer  "position",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tables", force: :cascade do |t|
    t.string   "title",                                   null: false
    t.integer  "number_of_players",  default: 1,          null: false
    t.datetime "start_time",                              null: false
    t.datetime "end_time",                                null: false
    t.text     "description",                             null: false
    t.text     "points_for_winners",                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id",                           null: false
    t.boolean  "opened",             default: true,       null: false
    t.integer  "entry_coins_cost",   default: 0,          null: false
    t.text     "coins_for_winners",  default: "--- []\n"
  end

  add_index "tables", ["title", "start_time", "end_time"], name: "index_tables_on_title_and_start_time_and_end_time", unique: true, using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",        null: false
    t.integer  "director_id", null: false
    t.text     "description", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "short_name",  null: false
  end

  add_index "teams", ["director_id"], name: "index_teams_on_director_id", unique: true, using: :btree
  add_index "teams", ["name"], name: "index_teams_on_name", unique: true, using: :btree

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tournaments", ["name"], name: "index_tournaments_on_name", unique: true, using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "coins"
    t.string   "detail"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_prizes", force: :cascade do |t|
    t.integer  "coins",      null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "table_id",   null: false
  end

  add_index "user_prizes", ["table_id", "user_id"], name: "index_user_prizes_on_table_id_and_user_id", unique: true, using: :btree
  add_index "user_prizes", ["user_id"], name: "index_user_prizes_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name",                          null: false
    t.string   "last_name",                           null: false
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
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "failed_attempts",        default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "provider"
    t.string   "uid"
    t.text     "image"
    t.string   "nickname",                            null: false
    t.integer  "invited_by_id"
    t.string   "telephone"
    t.string   "push_token"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid"], name: "index_users_on_uid", using: :btree

  create_table "wallets", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "coins",      default: 10, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wallets", ["user_id"], name: "index_wallets_on_user_id", unique: true, using: :btree

  add_foreign_key "notifications", "notification_types"
  add_foreign_key "notifications", "users"
  add_foreign_key "t_deposits", "users"
  add_foreign_key "t_entry_fees", "tables"
  add_foreign_key "t_entry_fees", "tournaments"
  add_foreign_key "t_entry_fees", "users"
  add_foreign_key "t_promotions", "users"
  add_foreign_key "user_prizes", "users"
end

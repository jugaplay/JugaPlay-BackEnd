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

ActiveRecord::Schema.define(version: 20171004124851) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "address_book_contacts", force: :cascade do |t|
    t.integer  "address_book_id",                     null: false
    t.integer  "user_id",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nickname",                            null: false
    t.boolean  "synched_by_email",    default: false, null: false
    t.boolean  "synched_by_facebook", default: false, null: false
    t.boolean  "synched_by_phone",    default: false
  end

  add_index "address_book_contacts", ["address_book_id", "user_id"], name: "index_address_book_contacts_on_address_book_id_and_user_id", unique: true, using: :btree

  create_table "address_books", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "address_books", ["user_id"], name: "index_address_books_on_user_id", unique: true, using: :btree

  create_table "closing_table_jobs", force: :cascade do |t|
    t.integer  "table_id",                  null: false
    t.integer  "priority",                  null: false
    t.integer  "status_cd",                 null: false
    t.datetime "stopped_at"
    t.string   "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "failures",      default: 0, null: false
  end

  add_index "closing_table_jobs", ["table_id"], name: "index_closing_table_jobs_on_table_id", unique: true, using: :btree

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

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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

  create_table "external_address_book_contacts", force: :cascade do |t|
    t.integer  "user_id",                 null: false
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       default: ""
  end

  add_index "external_address_book_contacts", ["user_id", "email", "phone"], name: "unique_email_and_phone_per_user", unique: true, using: :btree
  add_index "external_address_book_contacts", ["user_id"], name: "index_external_address_book_contacts_on_user_id", using: :btree

  create_table "group_invitation_tokens", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.string   "token",      null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "group_invitation_tokens", ["group_id"], name: "index_group_invitation_tokens_on_group_id", unique: true, using: :btree
  add_index "group_invitation_tokens", ["token"], name: "index_group_invitation_tokens_on_token", unique: true, using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", force: :cascade do |t|
    t.integer  "group_id",   null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups_users", ["group_id", "user_id"], name: "index_groups_users_on_group_id_and_user_id", unique: true, using: :btree
  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id"], name: "index_groups_users_on_user_id", using: :btree

  create_table "invitation_acceptances", force: :cascade do |t|
    t.integer  "invitation_request_id", null: false
    t.integer  "user_id",               null: false
    t.inet     "ip",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invitation_acceptances", ["invitation_request_id"], name: "index_invitation_acceptances_on_invitation_request_id", using: :btree
  add_index "invitation_acceptances", ["user_id", "invitation_request_id"], name: "unique_user_per_invitation_request", unique: true, using: :btree
  add_index "invitation_acceptances", ["user_id"], name: "index_invitation_acceptances_on_user_id", using: :btree

  create_table "invitation_requests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "token",      null: false
    t.integer  "user_id",    null: false
    t.string   "type",       null: false
  end

  add_index "invitation_requests", ["token"], name: "index_invitation_requests_on_token", unique: true, using: :btree
  add_index "invitation_requests", ["user_id"], name: "index_invitation_requests_on_user_id", using: :btree

  create_table "invitation_visits", force: :cascade do |t|
    t.integer  "invitation_request_id", null: false
    t.inet     "ip",                    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "league_rankings", force: :cascade do |t|
    t.integer  "user_id",      null: false
    t.integer  "league_id",    null: false
    t.integer  "round",        null: false
    t.integer  "position",     null: false
    t.float    "round_points", null: false
    t.float    "total_points", null: false
    t.integer  "status_cd",    null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "movement",     null: false
  end

  add_index "league_rankings", ["league_id"], name: "index_league_rankings_on_league_id", using: :btree
  add_index "league_rankings", ["status_cd"], name: "index_league_rankings_on_status_cd", using: :btree
  add_index "league_rankings", ["user_id", "league_id", "round"], name: "index_league_rankings_on_user_id_and_league_id_and_round", unique: true, using: :btree
  add_index "league_rankings", ["user_id"], name: "index_league_rankings_on_user_id", using: :btree

  create_table "league_rankings_plays", force: :cascade do |t|
    t.integer  "league_ranking_id", null: false
    t.integer  "play_id",           null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "league_rankings_plays", ["league_ranking_id"], name: "index_league_rankings_plays_on_league_ranking_id", using: :btree
  add_index "league_rankings_plays", ["play_id", "league_ranking_id"], name: "index_league_rankings_plays_on_play_id_and_league_ranking_id", unique: true, using: :btree
  add_index "league_rankings_plays", ["play_id"], name: "index_league_rankings_plays_on_play_id", using: :btree

  create_table "leagues", force: :cascade do |t|
    t.string   "title",             null: false
    t.string   "description",       null: false
    t.string   "image",             null: false
    t.text     "prizes_values",     null: false
    t.string   "prizes_type",       null: false
    t.integer  "status_cd",         null: false
    t.integer  "frequency_in_days", null: false
    t.integer  "periods",           null: false
    t.datetime "starts_at",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "leagues", ["starts_at"], name: "index_leagues_on_starts_at", using: :btree
  add_index "leagues", ["status_cd"], name: "index_leagues_on_status_cd", using: :btree

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

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "title",                      null: false
    t.string   "image"
    t.text     "text"
    t.text     "action"
    t.boolean  "read",       default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "type",                       null: false
  end

  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "notifications_settings", force: :cascade do |t|
    t.integer  "user_id",                    null: false
    t.boolean  "mail",       default: true,  null: false
    t.boolean  "sms",        default: false, null: false
    t.boolean  "whatsapp",   default: false, null: false
    t.boolean  "push",       default: false, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "facebook",   default: false, null: false
  end

  add_index "notifications_settings", ["user_id"], name: "index_notifications_settings_on_user_id", unique: true, using: :btree

  create_table "player_selections", force: :cascade do |t|
    t.integer  "play_id",    null: false
    t.integer  "player_id",  null: false
    t.integer  "position",   null: false
    t.float    "points",     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "player_selections", ["play_id", "player_id"], name: "index_player_selections_on_play_id_and_player_id", unique: true, using: :btree
  add_index "player_selections", ["play_id", "position"], name: "index_player_selections_on_play_id_and_position", unique: true, using: :btree
  add_index "player_selections", ["play_id"], name: "index_player_selections_on_play_id", using: :btree
  add_index "player_selections", ["player_id"], name: "index_player_selections_on_player_id", using: :btree

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

  create_table "plays", force: :cascade do |t|
    t.integer  "user_id",                  null: false
    t.integer  "table_id",                 null: false
    t.float    "points"
    t.float    "coins"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "cost_value", default: 0.0, null: false
    t.integer  "multiplier"
    t.string   "cost_type",                null: false
    t.integer  "type_cd",                  null: false
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

  create_table "sent_mails", force: :cascade do |t|
    t.string   "from"
    t.string   "to"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "t_deposits", force: :cascade do |t|
    t.float    "coins"
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
    t.float    "coins"
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
    t.float    "coins"
    t.string   "detail"
    t.string   "promotion_type"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "t_promotions", ["user_id"], name: "index_t_promotions_on_user_id", using: :btree

  create_table "table_rankings", force: :cascade do |t|
    t.integer  "position",                  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "play_id",                   null: false
    t.float    "points",      default: 0.0, null: false
    t.float    "prize_value",               null: false
    t.string   "prize_type",                null: false
  end

  add_index "table_rankings", ["play_id"], name: "index_table_rankings_on_play_id", unique: true, using: :btree

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

  create_table "tables", force: :cascade do |t|
    t.string   "title",                                      null: false
    t.integer  "number_of_players",     default: 1,          null: false
    t.datetime "start_time",                                 null: false
    t.datetime "end_time",                                   null: false
    t.text     "description",                                null: false
    t.text     "points_for_winners",    default: "--- []\n"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tournament_id",                              null: false
    t.float    "entry_cost_value",      default: 0.0,        null: false
    t.text     "prizes_values",         default: "--- []\n"
    t.integer  "group_id"
    t.integer  "status_cd",                                  null: false
    t.float    "multiplier_chips_cost", default: 0.0,        null: false
    t.string   "entry_cost_type",                            null: false
    t.string   "prizes_type",                                null: false
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

  create_table "telephone_update_requests", force: :cascade do |t|
    t.integer "user_id",                         null: false
    t.string  "telephone",                       null: false
    t.string  "validation_code",                 null: false
    t.boolean "applied",         default: false, null: false
  end

  add_index "telephone_update_requests", ["user_id", "validation_code"], name: "index_telephone_update_requests_on_user_id_and_validation_code", unique: true, using: :btree
  add_index "telephone_update_requests", ["user_id"], name: "index_telephone_update_requests_on_user_id", using: :btree
  add_index "telephone_update_requests", ["validation_code"], name: "index_telephone_update_requests_on_validation_code", using: :btree

  create_table "tournaments", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tournaments", ["name"], name: "index_tournaments_on_name", unique: true, using: :btree

  create_table "transactions", force: :cascade do |t|
    t.float    "coins"
    t.string   "detail"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

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
    t.string   "facebook_id"
    t.text     "image"
    t.string   "nickname",                            null: false
    t.string   "telephone"
    t.string   "push_token"
    t.string   "facebook_token"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["facebook_id"], name: "index_users_on_facebook_id", using: :btree
  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true, using: :btree
  add_index "users", ["provider"], name: "index_users_on_provider", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "wallets", force: :cascade do |t|
    t.integer  "user_id"
    t.float    "coins",      default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "chips",      default: 0.0, null: false
  end

  add_index "wallets", ["user_id"], name: "index_wallets_on_user_id", unique: true, using: :btree

  add_foreign_key "notifications", "users"
  add_foreign_key "t_deposits", "users"
  add_foreign_key "t_entry_fees", "tables"
  add_foreign_key "t_entry_fees", "tournaments"
  add_foreign_key "t_entry_fees", "users"
  add_foreign_key "t_promotions", "users"
end

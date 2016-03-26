class UpdateTablesWithNewStats < ActiveRecord::Migration
  def change
    remove_column :table_rules, :goals
    remove_column :table_rules, :passes

    add_column :table_rules, :shots,                    :float, null: false, default: 1
    add_column :table_rules, :shots_on_goal,            :float, null: false, default: 1
    add_column :table_rules, :shots_to_the_post,        :float, null: false, default: 1.5
    add_column :table_rules, :shots_outside,	          :float, null: false, default: 0
    add_column :table_rules, :scored_goals,	            :float, null: false, default: 10
    add_column :table_rules, :goalkeeper_scored_goals,	:float, null: false, default: 17
    add_column :table_rules, :defender_scored_goals,	  :float, null: false, default: 15
    add_column :table_rules, :free_kick_goal,	          :float, null: false, default: 2
    add_column :table_rules, :right_passes,	            :float, null: false, default: 0.5
    add_column :table_rules, :recoveries,	              :float, null: false, default: 3
    add_column :table_rules, :assists,	                :float, null: false, default: 6
    add_column :table_rules, :undefeated_defense,	      :float, null: false, default: 3
    add_column :table_rules, :forward_wrong_passes,	    :float, null: false, default: -0.5
    add_column :table_rules, :midfielder_wrong_passes,	:float, null: false, default: -0.5
    add_column :table_rules, :defender_wrong_passes,	  :float, null: false, default: -1
    add_column :table_rules, :tackles,	                :float, null: false, default: 2.5
    add_column :table_rules, :tackled_penalties,	      :float, null: false, default: 10
    add_column :table_rules, :missed_tackles,	          :float, null: false, default: -2
    add_column :table_rules, :undefeated_goal,	        :float, null: false, default: 5
    add_column :table_rules, :red_cards,	              :float, null: false, default: -10
    add_column :table_rules, :yellow_cards,	            :float, null: false, default: -2
    add_column :table_rules, :offside,	                :float, null: false, default: -1
    add_column :table_rules, :faults,	                  :float, null: false, default: -0.5
    add_column :table_rules, :missed_penalties,	        :float, null: false, default: -5
    add_column :table_rules, :winner_team,              :float, null: false, default: 2


    remove_column :player_stats, :goals
    remove_column :player_stats, :passes

    add_column :player_stats, :shots,                   :integer, null: false, default: 0
    add_column :player_stats, :shots_on_goal,           :integer, null: false, default: 0
    add_column :player_stats, :shots_to_the_post,       :integer, null: false, default: 0
    add_column :player_stats, :shots_outside,	          :integer, null: false, default: 0
    add_column :player_stats, :scored_goals,	          :integer, null: false, default: 0
    add_column :player_stats, :goalkeeper_scored_goals,	:integer, null: false, default: 0
    add_column :player_stats, :defender_scored_goals,	  :integer, null: false, default: 0
    add_column :player_stats, :free_kick_goal,	        :integer, null: false, default: 0
    add_column :player_stats, :right_passes,	          :integer, null: false, default: 0
    add_column :player_stats, :recoveries,	            :integer, null: false, default: 0
    add_column :player_stats, :assists,	                :integer, null: false, default: 0
    add_column :player_stats, :undefeated_defense,	    :integer, null: false, default: 0
    add_column :player_stats, :forward_wrong_passes,	  :integer, null: false, default: 0
    add_column :player_stats, :midfielder_wrong_passes,	:integer, null: false, default: 0
    add_column :player_stats, :defender_wrong_passes,	  :integer, null: false, default: 0
    add_column :player_stats, :tackles,	                :integer, null: false, default: 0
    add_column :player_stats, :tackled_penalties,	      :integer, null: false, default: 0
    add_column :player_stats, :missed_tackles,	        :integer, null: false, default: 0
    add_column :player_stats, :undefeated_goal,	        :integer, null: false, default: 0
    add_column :player_stats, :red_cards,	              :integer, null: false, default: 0
    add_column :player_stats, :yellow_cards,	          :integer, null: false, default: 0
    add_column :player_stats, :offside,	                :integer, null: false, default: 0
    add_column :player_stats, :faults,	                :integer, null: false, default: 0
    add_column :player_stats, :missed_penalties,	      :integer, null: false, default: 0
    add_column :player_stats, :winner_team,             :integer, null: false, default: 0
  end
end

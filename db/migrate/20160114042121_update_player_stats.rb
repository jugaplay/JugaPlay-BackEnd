class UpdatePlayerStats < ActiveRecord::Migration
  def change
    add_column :table_rules, :wrong_passes,	:float, null: false, default: -0.5

    remove_column :table_rules, :forward_wrong_passes
    remove_column :table_rules, :midfielder_wrong_passes
    remove_column :table_rules, :defender_wrong_passes

    rename_column :table_rules, :tackles, :saves
    rename_column :table_rules, :tackled_penalties, :saved_penalties
    rename_column :table_rules, :missed_tackles, :missed_saves

    add_column :player_stats, :wrong_passes, :float, null: false, default: 0

    remove_column :player_stats, :forward_wrong_passes
    remove_column :player_stats, :midfielder_wrong_passes
    remove_column :player_stats, :defender_wrong_passes

    rename_column :player_stats, :tackles, :saves
    rename_column :player_stats, :tackled_penalties, :saved_penalties
    rename_column :player_stats, :missed_tackles, :missed_saves
  end
end

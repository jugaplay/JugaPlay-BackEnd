class UpdateTableRules < ActiveRecord::Migration
  def change
    change_column :table_rules, :scored_goals,	          :float, null: false, default: 20
    change_column :table_rules, :goalkeeper_scored_goals,	:float, null: false, default: 27
    change_column :table_rules, :defender_scored_goals,	  :float, null: false, default: 25
  end
end

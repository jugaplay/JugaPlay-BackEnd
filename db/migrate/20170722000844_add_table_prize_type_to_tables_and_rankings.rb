class AddTablePrizeTypeToTablesAndRankings < ActiveRecord::Migration
  def up
    add_column :tables, :prizes_type, :string
    ActiveRecord::Base.connection.execute("UPDATE tables SET prizes_type = '#{Money::COINS}'")
    change_column :tables, :prizes_type, :string, null: false
    rename_column :tables, :coins_for_winners, :prizes_values

    add_column :table_rankings, :prize_type, :string
    ActiveRecord::Base.connection.execute("UPDATE table_rankings SET prize_type = '#{Money::COINS}'")
    change_column :table_rankings, :prize_type, :string, null: false
    rename_column :table_rankings, :earned_coins, :prize_value
  end

  def down
    remove_column :tables, :prizes_type
    rename_column :tables, :prizes_values, :coins_for_winners

    remove_column :table_rankings, :prize_type
    rename_column :table_rankings, :prize_value, :earned_coins
  end
end

class MoveCoinsToFloat < ActiveRecord::Migration
  def change
    change_column :tables, :entry_coins_cost, :float, null: false, default: 0.0
    change_column :plays, :bet_base_coins, :float, null: false, default: 0.0
    change_column :wallets, :coins, :float, null: false, default: 0.0
    change_column :table_rankings, :earned_coins, :float, null: false
    change_column :transactions, :coins, :float
    change_column :t_deposits, :coins, :float
    change_column :t_entry_fees, :coins, :float
    change_column :t_promotions, :coins, :float
  end
end

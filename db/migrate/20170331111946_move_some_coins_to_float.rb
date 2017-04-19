class MoveSomeCoinsToFloat < ActiveRecord::Migration
  def up
    change_column :wallets, :coins, :float, null: false, default: 10.0
    change_column :table_rankings, :earned_coins, :float, null: false
  end

  def down
    change_column :wallets, :coins, :integer, null: false, default: 10
    change_column :table_rankings, :earned_coins, :integer, null: false
  end
end

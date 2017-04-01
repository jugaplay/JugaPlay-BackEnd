class AddBetMultiplyCoins < ActiveRecord::Migration
  def change
    add_column :plays, :bet_multiplier, :integer, null: true
    rename_column :plays, :bet_coins, :bet_base_coins
  end
end

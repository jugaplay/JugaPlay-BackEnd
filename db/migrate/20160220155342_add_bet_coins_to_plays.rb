class AddBetCoinsToPlays < ActiveRecord::Migration
  def change
    add_column :plays, :bet_coins, :integer, null: false, default: 0
  end
end

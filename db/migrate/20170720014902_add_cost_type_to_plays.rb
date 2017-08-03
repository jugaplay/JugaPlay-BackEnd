class AddCostTypeToPlays < ActiveRecord::Migration
  def up
    add_column :plays, :cost_type, :string
    ActiveRecord::Base.connection.execute("UPDATE plays SET cost_type = '#{Money::COINS}'")
    change_column :plays, :cost_type, :string, null: false
    rename_column :plays, :bet_base_coins, :cost_value
    rename_column :plays, :bet_multiplier, :multiplier
  end

  def down
    remove_column :plays, :cost_type
    rename_column :plays, :cost_value, :bet_base_coins
    rename_column :plays, :multiplier, :bet_multiplier
  end
end

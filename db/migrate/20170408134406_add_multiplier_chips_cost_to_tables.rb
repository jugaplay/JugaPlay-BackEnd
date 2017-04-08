class AddMultiplierChipsCostToTables < ActiveRecord::Migration
  def change
    add_column :tables, :multiplier_chips_cost, :float, null: false, default: 0
  end
end

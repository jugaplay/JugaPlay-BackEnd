class AddEntryCostTypeToTables < ActiveRecord::Migration
  def up
    add_column :tables, :entry_cost_type, :string
    ActiveRecord::Base.connection.execute("UPDATE tables SET entry_cost_type = '#{Money::COINS}'")
    change_column :tables, :entry_cost_type, :string, null: false
    rename_column :tables, :entry_coins_cost, :entry_cost_value
  end

  def down
    remove_column :tables, :entry_cost_type
    rename_column :tables, :entry_cost_value, :entry_coins_cost
  end
end

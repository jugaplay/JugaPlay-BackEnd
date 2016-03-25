class AddEntryCoinsCostToTables < ActiveRecord::Migration
  def change
    add_column :tables, :entry_coins_cost, :integer, null: false, default: 0
  end
end

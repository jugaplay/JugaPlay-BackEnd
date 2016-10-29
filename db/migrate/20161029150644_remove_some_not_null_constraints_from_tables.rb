class RemoveSomeNotNullConstraintsFromTables < ActiveRecord::Migration
  def change
    change_column :tables, :coins_for_winners, :text, default: [], null: true
    change_column :tables, :points_for_winners, :text, default: [], null: true
  end
end

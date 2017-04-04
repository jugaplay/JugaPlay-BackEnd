class AddConstraintsToTableRankings < ActiveRecord::Migration
  def change
    change_column :table_rankings, :play_id, :integer, null: false
    add_index :table_rankings, :play_id, unique: true
  end
end

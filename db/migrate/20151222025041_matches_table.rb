class MatchesTable < ActiveRecord::Migration
  def change
    create_table :matches_tables do |t|
      t.references :match
      t.references :table

      t.timestamps
    end

    add_index :matches_tables, :match_id
    add_index :matches_tables, :table_id
  end
end

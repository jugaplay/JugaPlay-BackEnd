class CreatePlayerStats < ActiveRecord::Migration
  def change
    create_table :player_stats do |t|
      t.references :player, null: false
      t.references :match, null: false

      t.integer :goals, null: false, default: 0
      t.integer :passes, null: false, default: 0

      t.timestamps
    end

    add_index :player_stats, [:player_id, :match_id], unique: true
  end
end

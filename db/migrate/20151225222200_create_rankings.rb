class CreateRankings < ActiveRecord::Migration
  def change
    create_table :rankings do |t|
      t.references :tournament, null: false
      t.references :user, null: false
      t.float :points, null: false, default: 0
      t.integer :position, null: false

      t.timestamps
    end

    add_index :rankings, :tournament_id
    add_index :rankings, :user_id
    add_index :rankings, :position
    add_index :rankings, [:tournament_id, :user_id], unique: true
    add_index :rankings, [:tournament_id, :position], unique: true
  end
end

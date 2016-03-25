class CreatePlays < ActiveRecord::Migration
  def change
    create_table :plays do |t|
      t.references :user, null: false
      t.references :table, null: false
      t.float :points, default: nil

      t.timestamps
    end

    add_index :plays, :user_id
    add_index :plays, :table_id
    add_index :plays, [:user_id, :table_id], unique: true

    create_table :players_plays do |t|
      t.references :play, null: false
      t.references :player, null: false

      t.timestamps
    end

    add_index :players_plays, :play_id
    add_index :players_plays, [:play_id, :player_id], unique: true
  end
end

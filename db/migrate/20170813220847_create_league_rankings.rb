class CreateLeagueRankings < ActiveRecord::Migration
  def change
    create_table :league_rankings do |t|
      t.references :user, null: false, index: true
      t.references :league, null: false, index: true
      t.integer :round, null: false
      t.integer :position, null: false
      t.float :round_points, null: false
      t.float :total_points, null: false
      t.integer :status_cd, null: false, index: true
      t.timestamps
    end

    add_index :league_rankings, [:user_id, :league_id, :round], unique: true

    create_table :league_rankings_plays do |t|
      t.references :league_ranking, null: false, index: true
      t.references :play, null: false, index: true

      t.timestamps
    end

    add_index :league_rankings_plays, [:play_id, :league_ranking_id], unique: true
  end
end

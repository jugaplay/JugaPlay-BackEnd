class AddMovementToLeagueRankings < ActiveRecord::Migration
  def change
    add_column :league_rankings, :movement, :integer, null: false
  end
end

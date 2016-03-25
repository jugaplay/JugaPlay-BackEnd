class AddTournamentToMatches < ActiveRecord::Migration
  def up
    add_reference :matches, :tournament

    tournament = Tournament.first
    if tournament.present?
      tournament_data = { tournament_id: tournament.id }
      Match.update(Match.all.pluck(:id), Match.all.map { |_| tournament_data })
    end

    change_column :matches, :tournament_id, :integer, null: false
  end

  def down
    remove_column :matches, :tournament_id
  end
end

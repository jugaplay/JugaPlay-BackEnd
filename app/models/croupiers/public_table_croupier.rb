class PublicTableCroupier < Croupier
  protected

  def bet_coins(bet)
    bet ? table.entry_coins_cost : 0
  end

  def update_ranking
    ranking_points_updater.call
  end

  def validate_user_can_play(user)
    validate_user_did_not_play_yet user
  end

  def ranking_points_updater
    @ranking_points_updater ||= RankingPointsUpdater.new(tournament: table.tournament, points_for_winners: table.points_for_winners, users: winner_users)
  end
end

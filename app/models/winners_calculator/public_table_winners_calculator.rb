class PublicTableWinnersCalculator < TableWinnersCalculator
  protected

  def winner_users_ids
    @winner_users_ids ||= table.plays.order(points: :desc).joins(:user).
      joins("LEFT JOIN rankings ON (rankings.user_id = users.id AND rankings.tournament_id = #{ table.tournament.id })").
      order('rankings.position ASC').merge(User.ordered).limit(table.points_for_winners.count).pluck(:user_id)
  end
end

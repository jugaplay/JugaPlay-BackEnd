class PrivateTableWinnersCalculator < TableWinnersCalculator
  protected

  def winner_users_ids
    @winner_users_ids ||= table.plays.order(points: :desc).joins(:user).merge(User.ordered).pluck(:user_id)
  end
end

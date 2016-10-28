class PrivateTableCroupier < Croupier
  protected

  def bet_coins(bet)
    table.entry_coins_cost
  end

  def update_ranking
    # private tables do not add points for the tournament ranking
  end

  def create_play(players, user, bet_coins)
    user.pay_coins!(bet_coins)
    Play.create!(user: user, table: table, players: players, bet_coins: bet_coins)
  end

  def validate_user_can_play(user)
    validate_user_did_not_play_yet user
    validate_user_belongs_to_group user
  end

  def validate_user_belongs_to_group(user)
    fail UserDoesNotBelongToTableGroup unless table.can_play?(user)
  end
end

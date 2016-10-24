class PrivateTableCroupier < Croupier
  protected

  def bet_coins(bet)
    table.entry_coins_cost
  end

  def dispense_coins
    #TODO: move this to coins dispenser
    winner = winner_users.first
    coins = table.entry_coins_cost * table.group.size
    winner.win_coins! coins
    UserPrize.create!(coins: coins, user: winner, table: table)
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
    fail UserDoesNotBelongToTableGroup unless table.group.has_user? user
  end
end

class PrivateTableCoinsDispenser < CoinsDispenser
  def call
    winner = users.first
    coins = table.entry_coins_cost * table.amount_of_users_playing

    table.update!(coins_for_winners: [coins])
    winner.win_coins! coins
    UserPrize.create!(coins: coins, user: winner, table: table)
  end
end

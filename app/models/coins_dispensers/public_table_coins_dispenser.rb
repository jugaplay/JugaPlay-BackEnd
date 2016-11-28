class PublicTableCoinsDispenser < CoinsDispenser
  def call
    coins_for_winners = table.coins_for_winners
    User.transaction do
      users.each_with_index.each do |user, i|
        coins = coins_for_winners[i]
        if coins
          user.win_coins! coins
          Prize.create!(coins: coins, user: user, table: table)
        end
      end
    end
  end
end

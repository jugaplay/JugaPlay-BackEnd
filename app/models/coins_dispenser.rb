class CoinsDispenser
  def initialize(table:, users:)
    validate_arguments(table, users)
    @users, @table = users, table
  end
    
  def call
    coins_for_winners = table.coins_for_winners
    User.transaction do
 	    users.each_with_index.each do |user, i|
        coins = coins_for_winners[i]
        if coins
          user.win_coins! coins
          UserPrize.create!(coins: coins, user: user, table: table)
        end
      end
    end
  end

  private
  attr_reader :users, :table

  def validate_arguments(table, users)
    fail ArgumentError, 'Missing table' unless table.present?
    fail ArgumentError, 'Missing users' unless users.present?
  end
end

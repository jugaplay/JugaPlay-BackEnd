class CoinsDispenser
  def initialize(table)
    @table = table
  end
    
  def call
    update_private_table_coins_for_winners if table.private?
    dispense_coins_for_all_winners
  end

  protected
  attr_reader :table

  def update_private_table_coins_for_winners
    coins = table.entry_coins_cost * table.amount_of_users_playing
    table.update!(coins_for_winners: [coins]) if coins > 0
  end

  def dispense_coins_for_all_winners
    coins_for_winners = table.coins_for_winners
    TableRanking.transaction do
      table_winner_rankings.group_by(&:position).each do |position, table_rankings|
        table_coins = coins_for_winners[position - 1]
        if table_coins
          final_coins = (table_coins/table_rankings.size).round(2)
          table_rankings.each do |table_ranking|
            dispense_coins(final_coins, table_ranking)
          end
        end
      end
    end
  end

  def dispense_coins(coins, table_ranking)
    table_ranking.user.win_coins! coins
    table_ranking.update_attributes!(earned_coins: coins)
  end

  def table_winner_rankings
    @table_winner_rankings ||= table.table_rankings
  end
end

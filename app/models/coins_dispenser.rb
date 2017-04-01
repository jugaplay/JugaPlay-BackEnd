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
    TableRanking.transaction do
      table_winner_rankings.group_by(&:position).each do |position, table_rankings|
        coins_per_ranking = calculate_coins_per_raking(table, table_rankings, position)
        dispense_coins_for_each_ranking(table_rankings, coins_per_ranking) unless coins_per_ranking.zero?
      end
    end
  end

  def calculate_coins_per_raking(table, table_rankings, current_position)
    amount_of_plays = table_rankings.count
    coins_for_winners_from = current_position
    coins_for_winners_to = (current_position + amount_of_plays) - 1
    coins_for_all_rankings = (coins_for_winners_from..coins_for_winners_to).sum { |position| table.coins_for_position(position) }
    (coins_for_all_rankings/amount_of_plays).round(2)
  end

  def dispense_coins_for_each_ranking(table_rankings, coins_per_ranking)
    table_rankings.each do |table_ranking|
      final_coins = coins_per_ranking * table_ranking.play.coins_bet_multiplier
      dispense_coins(final_coins, table_ranking)
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

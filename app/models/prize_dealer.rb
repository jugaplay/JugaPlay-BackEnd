class PrizeDealer
  def initialize(table)
    @table = table
  end
    
  def call
    update_private_table_prize if table.private?
    deal_prizes_for_all_winners
  end

  protected
  attr_reader :table

  def update_private_table_prize
    prize = table.entry_cost * table.amount_of_users_playing
    table.update!(prizes: [prize]) unless prize.zero?
  end

  def deal_prizes_for_all_winners
    TableRanking.transaction do
      table_winner_rankings.group_by(&:position).each do |position, table_rankings|
        prize_per_ranking = calculate_prize_per_raking(table, table_rankings, position)
        dispense_prizes_for_each_ranking(table_rankings, prize_per_ranking) unless prize_per_ranking.zero?
      end
    end
  end

  def calculate_prize_per_raking(table, table_rankings, current_position)
    amount_of_plays = table_rankings.count
    prize_for_winners_from = current_position
    prize_for_winners_to = (current_position + amount_of_plays) - 1
    prize_for_all_rankings = (prize_for_winners_from..prize_for_winners_to).sum { |position| table.prize_for_position(position) }
    (prize_for_all_rankings / amount_of_plays).rounded
  end

  def dispense_prizes_for_each_ranking(table_rankings, prize_per_ranking)
    table_rankings.each do |table_ranking|
      multiplier = table_ranking.play.multiplier || 1
      final_prize = prize_per_ranking * multiplier
      deal_prize(final_prize, table_ranking)
    end
  end

  def deal_prize(prize, table_ranking)
    table_ranking.user.win_money! prize
    table_ranking.update_attributes!(prize: prize)
  end

  def table_winner_rankings
    @table_winner_rankings ||= table.table_rankings
  end
end

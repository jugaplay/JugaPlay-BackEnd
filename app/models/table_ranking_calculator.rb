class TableRankingCalculator

  def initialize(table)
    @table = table
    @rankings = []
  end

  def call
    build_paying_table_rankings
    build_training_table_rankings
    TableRanking.import(rankings)
  end

  private
  attr_reader :table, :rankings

  def build_paying_table_rankings
    next_position = 1
    winner_plays_sorter(table.paying_plays).call.each do |plays|
      position = next_position
      plays.each do |play|
        points = points_for_ranking(play)
        prize = Money.zero(table.prizes_type)
        rankings << TableRanking.new(play_id: play.id, position: position, points: points, prize: prize)
      end
      next_position += plays.count
    end
  end

  def build_training_table_rankings
    next_position = 1
    winner_plays_sorter(table.training_plays).call.each do |plays|
      position = next_position
      plays.each do |play|
        points = points_for_ranking(play)
        prize = Money.zero(table.entry_cost_type)
        rankings << TableRanking.new(play_id: play.id, position: position, points: points, prize: prize)
      end
      next_position += plays.count
    end
  end

  def points_for_ranking(play)
    [play.points, 0].max # Vamos a usar siempre los puntos de las jugadas
  end

  def winner_plays_sorter(plays)
    WinnerPlaysSorter.new(plays)
  end
end

class TableRankingCalculator

  def initialize(table)
    @table = table
    @rankings = []
    @winner_plays_sorter = WinnerPlaysSorter.new(table)
  end

  def call
    build_table_rankings
    TableRanking.import(rankings)
  end

  private
  attr_reader :table, :rankings, :winner_plays_sorter

  def build_table_rankings
    next_position = 1
    winner_plays_sorter.call.each do |plays|
      position = next_position
      points = points_for_ranking(plays.first, position)
      plays.each do |play|
        rankings << TableRanking.new(play_id: play.id, position: position, points: points, earned_coins: 0)
      end
      next_position += plays.count
    end
  end

  def points_for_ranking(play, position)
    return [play.points, 0].max unless table.has_points_for_winners?
    table.points_for_position(position)
  end
end

class TableRankingCalculator

  def initialize(table)
    @table = table
  end

  def call
    rankings = []
    sorted_table_plays.each_with_index do |play, index|
      position = index + 1
      points = points_for_ranking(play, position)
      rankings << TableRanking.new(play_id: play.id, position: position, points: points, earned_coins: 0)
    end
    TableRanking.import(rankings)
  end

  private
  attr_reader :table

  def points_for_ranking(play, position)
    return [play.points, 0].max unless table.has_points_for_winners?
    table.points_for_position(position)
  end

  def sorted_table_plays
    return sorted_private_table_plays if table.private?
    sorted_public_table_plays
  end

  def sorted_private_table_plays
    table.plays.order(points: :desc).joins(:user).merge(User.ordered)
  end

  def sorted_public_table_plays
    table.plays.order(points: :desc).joins(:user).
      joins("LEFT JOIN rankings ON (rankings.user_id = users.id AND rankings.tournament_id = #{ table.tournament.id })").
      order('rankings.position ASC').merge(User.ordered)
  end
end

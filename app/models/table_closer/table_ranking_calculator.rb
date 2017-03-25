class TableRankingCalculator

  def initialize(table)
    @table = table
  end

  def call
    rankings = []
    winner_play_ids.each_with_index do |play_id, i|
      position = i + 1
      points = table.points_for_position(position)
      rankings << TableRanking.new(play_id: play_id, position: position, points: points, earned_coins: 0)
    end
    TableRanking.import(rankings)
  end

  private
  attr_reader :table

  def winner_play_ids
    return private_winner_play_ids if table.private?
    public_winner_play_ids
  end

  def private_winner_play_ids
    table.plays.order(points: :desc).joins(:user).merge(User.ordered).pluck('plays.id')
  end

  def public_winner_play_ids
    table.plays.order(points: :desc).joins(:user).
      joins("LEFT JOIN rankings ON (rankings.user_id = users.id AND rankings.tournament_id = #{ table.tournament.id })").
      order('rankings.position ASC').merge(User.ordered).pluck('plays.id')
  end
end

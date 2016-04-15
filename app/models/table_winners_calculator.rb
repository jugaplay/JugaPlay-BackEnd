class TableWinnersCalculator

  def initialize(table)
    fail ArgumentError, 'A table must be given' if table.nil?
    @table, @winners = table, []
  end

  def call
    create_table_winners
    winners.map(&:user)
  end

  private
  attr_reader :table, :winners

  def create_table_winners
    winner_users_ids.each_with_index do |user_id, i|
      winners << TableWinner.new(user_id: user_id, table: table, position: i + 1)
    end
    TableWinner.import(winners)
  end

  def winner_users_ids
    @winner_users_ids ||= table.plays.order(points: :desc).joins(:user).
      joins("LEFT JOIN rankings ON (rankings.user_id = users.id AND rankings.tournament_id = #{ table.tournament.id })").
      order('rankings.position ASC').merge(User.ordered).limit(table.points_for_winners.count).pluck(:user_id)
  end
end

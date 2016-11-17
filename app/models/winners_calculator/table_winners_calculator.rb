class TableWinnersCalculator
  def self.for(table)
    fail ArgumentError, 'A table must be given' if table.nil?
    return PrivateTableWinnersCalculator.new(table) if table.private?
    PublicTableWinnersCalculator.new(table)
  end

  def initialize(table)
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
    fail 'subclass responsibility'
  end
end

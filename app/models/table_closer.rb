class TableCloser

  def initialize(table)
    @table = table
    @table_closer_validator = TableCloserValidator.new
    @play_points_assigner = PlayPointsAssigner.new(table)
    @table_ranking_calculator = TableRankingCalculator.new(table)
    @prize_dealer = PrizeDealer.new(table)
    @ranking_points_updater = RankingPointsUpdater.new(table)
    @ranking_sorter = RankingSorter.new(table.tournament)
  end

  def call
    table_closer_validator.validate_to_finish_closing table
    play_points_assigner.call
    table_ranking_calculator.call
    if table.has_rankings?
      prize_dealer.call
      ranking_points_updater.call if table.public?
    end
    table.close!
    ranking_sorter.call
  end

  private
  attr_reader :table, :table_closer_validator, :play_points_assigner, :table_ranking_calculator, :prize_dealer, :ranking_points_updater, :ranking_sorter
end

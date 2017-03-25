class TableCloser

  def initialize(table)
    @table = table
    @player_points_calculator = PlayerPointsCalculator.new
    @play_points_assigner = PlayPointsAssigner.new(table)
    @table_ranking_calculator = TableRankingCalculator.new(table)
    @coins_dispenser = CoinsDispenser.new(table)
    @ranking_points_updater = RankingPointsUpdater.new(table)
    @ranking_sorter = RankingSorter.new(table.tournament)
  end

  def call

  end

  private
  attr_reader :table

end
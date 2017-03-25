class PlayPointsAssigner

  def initialize(table)
    @table = table
    @player_points_calculator = PlayerPointsCalculator.new
    @table_ranking_calculator = TableRankingCalculator.new(table)
    @coins_dispenser = CoinsDispenser.new(table)
    @ranking_points_updater = RankingPointsUpdater.new(table)
  end

  def assign_points(players_stats:)
    validate_players_stats(players_stats)
    calculate_play_points(players_stats)
    table_ranking_calculator.call
    if table.has_ranking?
      coins_dispenser.call
      ranking_points_updater.call if table.public?
    end
    table.close!
  end

  protected
  attr_reader :table, :player_points_calculator, :table_ranking_calculator, :play_ids_to_update, :play_data_to_update, :coins_dispenser, :ranking_points_updater

  def calculate_play_points(players_stats)
    @play_ids_to_update, @play_data_to_update = [], []
    plays.find_each { |play| update_data_for_play_with(play, players_stats) }
    Play.update(play_ids_to_update, play_data_to_update)
  end

  def update_data_for_play_with(play, players_stats)
    applicable_stats = players_stats.select { |player_stats| play.involves_player? (player_stats.player) }
    fail MissingPlayerStats if applicable_stats.empty?
    play_ids_to_update << play.id
    play_data_to_update << { points: player_points_calculator.call(table, applicable_stats) }
  end

  def plays
    Play.where(table: table)
  end

  def validate_players_stats(players_stats)
    fail MissingPlayerStats unless table.can_be_closed_with_stats?(players_stats)
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players_stats.map(&:player))
  end
end

class PlayPointsAssigner
  def initialize(table)
    @table = table
    @points_calculator = PlayPointsCalculator.new
    @winners_calculator = TableWinnersCalculator.for(table)
  end

  def assign_points(players_stats:)
    validate_players_stats(players_stats)
    calculate_play_points(players_stats)
    unless winner_users.empty?
      coins_dispenser.call
      ranking_points_updater.call if table.public?
    end
    table.close!
  end

  protected
  attr_reader :table, :points_calculator, :winners_calculator, :play_ids_to_update, :play_data_to_update

  def calculate_play_points(players_stats)
    @play_ids_to_update, @play_data_to_update = [], []
    plays.find_each { |play| update_data_for_play_with(play, players_stats) }
    Play.update(play_ids_to_update, play_data_to_update)
  end

  def update_data_for_play_with(play, players_stats)
    applicable_stats = players_stats.select { |player_stats| play.involves_player? (player_stats.player) }
    fail MissingPlayerStats if applicable_stats.empty?
    play_ids_to_update << play.id
    play_data_to_update << { points: points_calculator.call(table.table_rules, applicable_stats) }
  end

  def winner_users
    @winner_users ||= winners_calculator.call
  end

  def coins_dispenser
    @coins_dispenser ||= CoinsDispenser.for(table: table, users: winner_users)
  end

  def ranking_points_updater
    @ranking_points_updater ||= RankingPointsUpdater.new(tournament: table.tournament, points_for_winners: table.points_for_winners, users: winner_users)
  end

  def plays
    Play.where(table: table)
  end

  def validate_players_stats(players_stats)
    fail MissingPlayerStats unless table.can_be_closed_with_stats?(players_stats)
    fail PlayerDoesNotBelongToTable unless table.include_all_players?(players_stats.map(&:player))
  end
end

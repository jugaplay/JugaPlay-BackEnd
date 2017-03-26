class PlayPointsAssigner

  def initialize(table)
    @table = table
    @play_ids_to_update = []
    @play_data_to_update = []
    @player_points_calculator = PlayerPointsCalculator.new
  end

  def call
    plays.find_each do |play|
      update_data_for_play_with(play, players_stats)
    end
    Play.update(play_ids_to_update, play_data_to_update)
  end

  protected
  attr_reader :table, :play_ids_to_update, :play_data_to_update, :player_points_calculator

  def update_data_for_play_with(play, players_stats)
    applicable_stats = players_stats.select { |player_stats| play.involves_player? (player_stats.player) }
    fail MissingPlayerStats if applicable_stats.empty?
    play_ids_to_update << play.id
    play_data_to_update << { points: player_points_calculator.call(table, applicable_stats) }
  end

  def players_stats
    @players_stats ||= PlayerStats.for_table(table)
  end

  def plays
    @plays ||= Play.where(table: table)
  end
end

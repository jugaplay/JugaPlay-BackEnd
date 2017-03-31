class PlayPointsAssigner

  def initialize(table)
    @table = table
    @play_ids_to_update = []
    @play_data_to_update = []
    @player_points_calculator = PlayerPointsCalculator.new
  end

  def call
    plays.find_each do |play|
      update_data_for_play(play)
    end
    Play.update(play_ids_to_update, play_data_to_update)
  end

  protected
  attr_reader :table, :play_ids_to_update, :play_data_to_update, :player_points_calculator

  def update_data_for_play(play)
    play_ids_to_update << play.id
    play_data_to_update << { points: calculate_points_for_play(play)}
  end

  def calculate_points_for_play(play)
    play.player_selections.map do |player_selection|
      points = player_points_calculator.call(table, player_selection.player)
      player_selection.update_attributes!(points: points)
      points
    end.sum.round(2)
  end

  def plays
    @plays ||= table.plays
  end
end

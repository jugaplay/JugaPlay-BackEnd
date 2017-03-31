class PlayerPointsCalculator

  def call(table, player)
    @table, @player = table, player
    calculate_points_for_player(player, table)
  end

  private
  attr_reader :table, :player

  def calculate_points_for_player(player, table)
    player_stats = PlayerStats.for_table_and_player(table, player)
    fail MissingPlayerStats if player_stats.empty?
    player_stats.map do |stat|
      calculate_for_player_stat(stat)
    end.sum.round(2)
  end

  def calculate_for_player_stat(player_stat)
    PlayerStats::FEATURES.map { |feature| scored_points(player_stat, feature) }.sum.round(2)
  end

  def scored_points(player_stat, feature)
    player_stat.send(feature) * table_rules.send(feature)
  end

  def table_rules
    @table_rules ||= table.table_rules
  end
end

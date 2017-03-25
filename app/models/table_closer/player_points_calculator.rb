class PlayerPointsCalculator

  def call_for_player(table, player)
    matches_ids = table.matches.map(&:id)
    player_stats = PlayerStats.where(player_id: player, match_id: matches_ids)
    call(table, player_stats)
  end

  def call(table, players_stats)
    @table_rules, @players_stats = table.table_rules, players_stats
    PlayerStats::FEATURES.map { |feature| calculate_points_for_feature(feature) }.sum.round(2)
  end

  private
  attr_reader :table_rules, :players_stats

  def calculate_points_for_feature(feature)
    total_scored_for_feature(feature) * table_rules.send(feature)
  end

  def total_scored_for_feature(feature)
    players_stats.map { |player_stats| player_stats.send(feature) }.sum
  end
end

class PlayPointsCalculator

  def call_for_player(play, player)
    table_rules = play.table.table_rules
    matches_ids = table_rules.table.matches.map(&:id)
    player_stats = PlayerStats.where(player_id: player, match_id: matches_ids)
    call(table_rules, player_stats)
  end

  def call(table_rules, players_stats)
    assign_and_validate(players_stats, table_rules)
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

  def assign_and_validate(players_stats, table_rules)
    @table_rules, @players_stats = table_rules, players_stats
    fail ArgumentError, 'No table rules where given' if table_rules.nil?
    fail ArgumentError, 'No player stats where given' if players_stats.nil?
  end
end

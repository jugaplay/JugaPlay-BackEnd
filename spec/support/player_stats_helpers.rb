module PlayerStatsHelpers
  def create_empty_stats_for_all(matches)
    matches.each { |match| create_empty_stats_for match }
  end

  def create_empty_stats_for(match)
    match.players.each do |player|
      PlayerStats.create!(player: player, match: match) unless PlayerStats.where(player: player, match: match).exists?
    end
  end
end

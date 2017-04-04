module PlayerStatsHelpers
  def create_empty_stats_for_all(matches)
    matches.each { |match| create_empty_stats_for match }
  end

  def create_empty_stats_for(match)
    create_empty_stats_for_local_team match
    create_empty_stats_for_visitor_team match
  end

  def create_empty_stats_for_local_team(match)
    match.local_team.players.each do |player|
      create_empty_stats_for_player(match, player)
    end
  end

  def create_empty_stats_for_visitor_team(match)
    match.visitor_team.players.each do |player|
      create_empty_stats_for_player(match, player)
    end
  end

  def create_empty_stats_for_player(match, player)
    PlayerStats.create!(player: player, match: match) unless PlayerStats.where(player: player, match: match).exists?
  end
end

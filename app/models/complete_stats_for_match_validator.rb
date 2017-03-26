class CompleteStatsForMatchValidator
  def validate_table(table)
    validate_matches table.matches
  end

  def validate_matches(matches)
    matches.each { |match| validate match }
  end

  def validate(match)
    match.players.each do |player|
      exists = PlayerStats.where(match: match, player: player).exists?
      raise MissingPlayerStats.for(player, match) unless exists
    end
  end
end

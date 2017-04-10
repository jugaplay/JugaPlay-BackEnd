class TableCloserValidator
  def validate_to_start_closing(table)
    validate_table_is_open table
    validate_matches table.matches
  end

  def validate_to_finish_closing(table)
    validate_table_is_being_closed table
    validate_matches table.matches
  end

  private

  def validate_table_is_open(table)
    raise TableIsClosed.for(table) unless table.opened?
  end

  def validate_table_is_being_closed(table)
    raise TableIsNotBeingClosed.for(table) unless table.being_closed?
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

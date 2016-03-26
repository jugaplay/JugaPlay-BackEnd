require 'csv'

class PlayerStatsCSVImporter
  def initialize(file, table)
    raise ArgumentError, 'A file must be given' if file.nil?
    @csv = CSV.parse(File.read(file.path), headers: true)
    @table = table
    @player_stats_data = []
  end

  def import
    csv.each { |row| player_stats_data << row.to_hash }
    validate_players_and_matches
    ActiveRecord::Base.transaction do
      PlayerStats.create! player_stats_data
    end
  end

  private
  attr_reader :table, :csv, :player_stats_data

  def validate_players_and_matches
    players_ids, matches_ids = [], []
    player_stats_data.each do |data|
      players_ids << data['player_id']
      matches_ids << data['match_id']
    end
    raise ArgumentError, 'Match not included in the given table' unless table.include_all_matches? Match.where(id: matches_ids.uniq)
    raise ArgumentError, 'Player is not included in the given table' unless table.include_all_players? Player.where(id: players_ids.uniq)
  end
end

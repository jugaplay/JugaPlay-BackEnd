require 'csv'

class PlayerStatsCSVImporter
  def initialize(file)
    raise ArgumentError, 'A file must be given' if file.nil?
    @csv = CSV.parse(File.read(file.path), headers: true)
    @player_stats_data = []
    @errors = []
  end

  def import
    read_data
    create_player_stats
    errors
  end

  private
  attr_reader :csv, :player_stats_data, :errors

  def read_data
    csv.each { |row| player_stats_data << row.to_hash }
  end

  def create_player_stats
    PlayerStats.transaction do
      player_stats_data.each do |player_stat_data|
        player_stats = PlayerStats.create(player_stat_data)
        errors << player_stats.errors.full_messages.join(', ') unless player_stats.valid?
      end
    end
  end
end

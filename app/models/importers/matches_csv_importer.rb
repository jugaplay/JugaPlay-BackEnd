require 'csv'

class MatchesCSVImporter
  def initialize(file_path)
    raise ArgumentError, 'A file must be given' if file_path.nil?
    @csv = CSV.parse(File.read(File.open(file_path)), headers: true)
    @matches_data = []
  end

  def import
    csv.each { |row| matches_data << row.to_hash }
    validate_and_parse_matches_data
    ActiveRecord::Base.transaction do
      Match.create! matches_data
    end
  end

  private
  attr_reader :csv, :matches_data

  def validate_and_parse_matches_data
    matches_data.each do |data|
      Team.find(data['local_team_id'])
      Team.find(data['visitor_team_id'])
      Tournament.find(data['tournament_id'])
      data['datetime'] = DateTime.strptime(data['datetime'], '%d/%m/%y %H:%M')
    end
  end
end

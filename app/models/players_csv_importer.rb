require 'csv'

class PlayersCSVImporter
  def initialize(team, file)
    raise ArgumentError, 'A team must be given' if team.nil?
    raise ArgumentError, 'A file must be given' if file.nil?
    @csv = CSV.parse(File.read(file.path), headers: true)
    @team = team
    @players_data = []
  end

  def import
    csv.each { |row| players_data << row.to_hash }
    validate_and_parse_players_data
    create_players
  end

  private
  attr_reader :csv, :players_data, :team

  def validate_and_parse_players_data
    players_data.each do |data|
      data['team_id'] = team.id
      data['birthday'] = Date.strptime(data['birthday'], '%d/%m/%Y')
      data['data_factory_players_mapping'] = DataFactoryPlayersMapping.new(data_factory_id: data.delete('data_factory_id'))
    end
  end

  def create_players
    players = []
    players_data.each do |player_data|
      player = Player.new(player_data)
      if player.valid?
        players << player
      else
        message = 'There was an error trying to import player:'
        player_data.each { |key, value| message += "\n#{key}: #{value}" }
        message += "\nERROR: #{player.errors.join(', ')}"
        fail ArgumentError, message
      end
    end
    Player.transaction { players.each(&:save!) }
  end
end

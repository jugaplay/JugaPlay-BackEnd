class MissingPlayerStats < StandardError
  def self.for(player, match)
    new "Missing required stats for #{player.name} for match #{match.title}"
  end

  def initialize(message = 'Missing required player stats')
    super message
  end
end

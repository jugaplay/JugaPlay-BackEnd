class MissingPlayerStats < StandardError
  def self.for(player, match)
    new "Missing required stats for #{player.name} for match #{match.title}"
  end

  def initialize(msg)
    super (msg || 'Missing required player stats')
  end
end

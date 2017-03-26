class MissingPlayerStats < StandardError
  def self.for(player, match)
    new "Missing required stats for #{player.name} for match #{match.title}"
  end

  def initialize(msg = nil)
    super (msg || 'Missing required player stats')
  end
end

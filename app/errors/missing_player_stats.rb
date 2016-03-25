class MissingPlayerStats < StandardError
  def initialize
    super 'Missing required player stats'
  end
end

class CanNotPlayWithNumberOfPlayers < StandardError
  def initialize
    super 'The amount of given players is not allowed in this table'
  end
end

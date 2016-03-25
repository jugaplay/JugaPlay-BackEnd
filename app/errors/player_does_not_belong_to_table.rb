class PlayerDoesNotBelongToTable < StandardError
  def initialize
    super 'Cannot choose this player for this table'
  end
end

class PlayWithDuplicatedPlayer < StandardError
  def initialize
    super 'Player is already involved in this play'
  end
end

class GivenPlayWasNotWinner < StandardError
  def initialize
    super 'Given play was not a winner'
  end
end

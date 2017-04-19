class UserDoesNotHaveEnoughChips < StandardError
  def initialize
    super 'User does not have enough chips to buy a multiplier'
  end
end

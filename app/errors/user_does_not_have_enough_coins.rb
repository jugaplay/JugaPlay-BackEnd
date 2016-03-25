class UserDoesNotHaveEnoughCoins < StandardError
  def initialize
    super 'User does not have enough coins to bet'
  end
end

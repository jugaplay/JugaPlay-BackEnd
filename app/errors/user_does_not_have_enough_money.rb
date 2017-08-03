class UserDoesNotHaveEnoughMoney < StandardError
  def self.for(currency)
    new "User does not have enough #{currency}"
  end

  def initialize(message = 'User does not have enough money')
    super message
  end
end

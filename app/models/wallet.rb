class Wallet < ActiveRecord::Base
  COINS_PER_INVITATION = 5

  belongs_to :user
  
  validates :user, presence: true, uniqueness: true
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :credits, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }

  def subtract_coins!(amount_of_coins)
    update_attributes!(coins: coins - amount_of_coins)
  end

  def add_coins!(amount_of_coins)
    update_attributes!(coins: coins + amount_of_coins)
  end

  def subtract_credits!(amount_of_credits)
    update_attributes!(credits: credits - amount_of_credits)
  end

  def add_credits!(amount_of_credits)
    update_attributes!(coins: credits + amount_of_credits)
  end  
  
  
end

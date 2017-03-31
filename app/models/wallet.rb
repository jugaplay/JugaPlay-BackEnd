class Wallet < ActiveRecord::Base
  COINS_PER_INVITATION = 10
  COINS_PER_REGISTRATION = 10

  belongs_to :user
  
  validates :user, presence: true, uniqueness: true
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  def subtract_coins!(amount_of_coins)
    update_attributes!(coins: coins - amount_of_coins)
  end

  def add_coins!(amount_of_coins)
    update_attributes!(coins: coins + amount_of_coins)
  end
end

class Wallet < ActiveRecord::Base
  INVITATION_PRIZE = 10.chips
  REGISTRATION_PRIZE = 30.chips

  belongs_to :user
  
  validates :user, presence: true, uniqueness: true
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :chips, numericality: { greater_than_or_equal_to: 0, allow_nil: false }

  def coins
    Money.coins(self[:coins])
  end

  def chips
    Money.chips(self[:chips])
  end

  def coins=(money)
    return self[:coins] = money.value if money.is_a?(Money) && money.coins?
    errors.add(:coins, 'Given money must be coins')
    fail ActiveRecord::RecordInvalid.new self
  end

  def chips=(money)
    return self[:chips] = money.value if money.is_a?(Money) && money.chips?
    errors.add(:coins, 'Given money must be chips')
    fail ActiveRecord::RecordInvalid.new self
  end

  def has_money?(money)
    money.based_on_currency_do proc { return has_coins? money },
                               proc { return has_chips? money }
  end

  def subtract!(money)
    money.based_on_currency_do proc { return subtract_coins! money },
                               proc { return subtract_chips! money }
  end

  def add!(money)
    money.based_on_currency_do proc { return add_coins! money },
                               proc { return add_chips! money }
  end

  private

  def has_coins?(money)
    coins >= money
  end

  def has_chips?(money)
    chips >= money
  end

  def subtract_coins!(amount_of_coins)
    update_attributes!(coins: coins - amount_of_coins)
  end

  def subtract_chips!(amount_of_chips)
    update_attributes!(chips: chips - amount_of_chips)
  end

  def add_coins!(amount_of_coins)
    update_attributes!(coins: coins + amount_of_coins)
  end

  def add_chips!(amount_of_chips)
    update_attributes!(chips: chips + amount_of_chips)
  end
end

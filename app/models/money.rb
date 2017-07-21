class Money
  CHIPS = 'chips'
  COINS = 'coins'
  CURRENCIES = [CHIPS, COINS]

  def self.coins(value)
    new COINS, value
  end

  def self.chips(value)
    new CHIPS, value
  end

  def self.zero(currency)
    new currency, 0
  end

  def initialize(currency, value)
    validate_currency currency
    value = value.to_f if value.integer?
    validate_value value
    @currency, @value = currency, value
  end

  def >=(another_money)
    validate_same_currency self, another_money
    value >= another_money.value
  end

  def +(another_money)
    validate_same_currency self, another_money
    Money.new(currency, value + another_money.value)
  end

  def -(another_money)
    validate_same_currency self, another_money
    Money.new(currency, value - another_money.value)
  end

  def *(a_number)
    Money.new(currency, value * a_number)
  end

  def coins?
    if COINS.eql? currency
      yield if block_given?
      true
    end
  end

  def chips?
    if CHIPS.eql? currency
      yield if block_given?
      true
    end
  end

  def based_on_currency_do(coins_block, chips_block)
    coins? { return coins_block.call }
    chips? { return chips_block.call }
  end

  def has_value?(another_value)
    value.eql? another_value
  end

  def has_currency?(another_currency)
    currency.eql? another_currency
  end

  def eql?(another_money)
    return false unless another_money.is_a? Money
    has_currency?(another_money.currency) && has_value?(another_money.value)
  end
  alias :== :eql?

  def to_s
    "#{value} #{currency}"
  end

  def self.valid_currency?(currency)
    CURRENCIES.include? currency
  end

  attr_reader :currency, :value
  private

  def validate_same_currency(a_money, another_money)
    fail ArgumentError, 'Can not operate between moneys from different currencies' unless a_money.has_currency?(another_money.currency)
  end

  def validate_currency(currency)
    fail ArgumentError, "Given currency is not valid, must be included in [#{CURRENCIES.join(', ')}]" unless self.class.valid_currency?(currency)
  end

  def validate_value(value)
    fail ArgumentError, 'Given value must be greater than or equal to 0' if value < 0
  end
end

class MoneyListParser
  def initialize(default_currency = Money::COINS)
    @default_currency = default_currency
  end

  def parse!(moneys, &on_fail_block)
    return default_currency, [] if moneys.empty?
    return moneys.first.currency, moneys.map(&:value) if same_currency?(moneys)
    on_fail_block.call
  end

  private
  attr_reader :default_currency

  def same_currency?(moneys)
    return false unless all_moneys?(moneys)
    moneys.map(&:currency).uniq.length.eql?(1)
  end

  def all_moneys?(moneys)
    moneys.all? { |money| money.is_a?(Money) }
  end
end

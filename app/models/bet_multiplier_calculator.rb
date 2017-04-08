class BetMultiplierCalculator
  def call(play, multiplier)
    user = play.user
    table = play.table
    validate_table_has_multiplier_chips_cost table
    required_chips = calculate_required_chips table, multiplier
    validate_enough_chips_for user, required_chips
    play.bet_multiplier_by(multiplier)
    user.pay_chips! required_chips
  end

  private

  def calculate_required_chips(table, multiplier)
    chips = (table.multiplier_chips_cost * multiplier) / 2.0
    chips.round(2)
  end

  def validate_enough_chips_for(user, required_chips)
    fail UserDoesNotHaveEnoughChips unless user.has_chips?(required_chips)
  end

  def validate_table_has_multiplier_chips_cost(table)
    fail TableDoesNotHaveAMultiplierChipsCostDefined if table.multiplier_chips_cost.zero?
  end
end

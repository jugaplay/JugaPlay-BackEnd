class PrivateTablePlayCreator < PlaysCreator
  protected

  def bet_base_coins(bet)
    table.entry_coins_cost
  end

  def validate_user_can_play(user)
    validate_user_has_not_played user
    validate_user_belongs_to_group user
  end

  def validate_user_belongs_to_group(user)
    fail UserDoesNotBelongToTableGroup unless table.can_play?(user)
  end
end

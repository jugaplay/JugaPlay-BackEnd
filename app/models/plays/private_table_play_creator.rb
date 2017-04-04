class PrivateTablePlayCreator < PlaysCreator
  protected

  def bet_coins(bet)
    table.entry_coins_cost
  end

  def validate_user_can_play(user)
    validate_user_did_not_play_yet user
    validate_user_belongs_to_group user
  end

  def validate_user_belongs_to_group(user)
    fail UserDoesNotBelongToTableGroup unless table.can_play?(user)
  end
end

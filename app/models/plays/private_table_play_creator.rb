class PrivateTablePlayCreator < PlaysCreator
  protected

  def entry_cost(bet)
    table.entry_cost
  end

  def validate_user_can_play(user)
    validate_user_has_not_played user
    validate_user_belongs_to_group user
  end

  def play_type(bet)
    :challenge
  end

  def validate_user_belongs_to_group(user)
    fail UserDoesNotBelongToTableGroup unless table.can_play?(user)
  end
end

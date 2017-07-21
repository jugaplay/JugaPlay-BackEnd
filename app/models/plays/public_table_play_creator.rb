class PublicTablePlayCreator < PlaysCreator
  protected

  def entry_cost(bet)
    bet ? table.entry_cost : Money.zero(table.entry_cost_type)
  end

  def validate_user_can_play(user)
    validate_user_has_not_played user
  end
end

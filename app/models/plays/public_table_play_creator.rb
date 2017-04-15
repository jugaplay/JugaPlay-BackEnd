class PublicTablePlayCreator < PlaysCreator
  protected

  def bet_base_coins(bet)
    bet ? table.entry_coins_cost : 0
  end

  def validate_user_can_play(user)
    validate_user_has_not_played user
  end
end

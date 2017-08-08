json.array! @tables do |table|
  json.id table.id
  json.title table.title
  json.has_password false # TODO: sacar esto
  json.entry_cost_value table.entry_cost.value
  json.entry_cost_type table.entry_cost.currency
  json.multiplier_chips_cost table.multiplier_chips_cost
  json.number_of_players table.number_of_players
  json.pot_prize_type table.pot_prize.currency
  json.pot_prize_value table.pot_prize.value
  json.start_time table.start_time.strftime('%d/%m/%Y - %H:%M')
  json.end_time table.end_time.strftime('%d/%m/%Y - %H:%M')
  json.description table.description
  json.has_been_played_by_user table.has_played?(current_user)
  json.played_by_user_type table.play_type_for(current_user)
  json.multiplier table.multiplier_for(current_user)
  json.tournament_id  table.tournament_id
  json.private table.private?
  json.amount_of_users_playing table.amount_of_users_playing
  json.amount_of_users_challenge table.challenge_plays.count
  json.amount_of_users_league table.league_plays.count
  json.amount_of_users_training table.training_plays.count

  # POR RETROCOMPATIBILIDAD #
  json.entry_coins_cost (table.entry_cost.coins? ? table.entry_cost.value : 0)
  json.pot_prize (table.pot_prize.coins? ? table.pot_prize.value : 0)
  json.bet_multiplier table.multiplier_for(current_user)
  ###########################

  if table.private?
    json.group do
      json.name table.group.name
      json.size table.group.size
    end
  end
end

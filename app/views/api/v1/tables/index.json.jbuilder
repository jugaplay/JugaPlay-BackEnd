json.array! @tables do |table|
  json.id table.id
  json.title table.title
  json.has_password false # TODO: sacar esto
  json.entry_cost_value table.entry_cost.value
  json.entry_cost_type table.entry_cost.currency
  json.multiplier_chips_cost table.multiplier_chips_cost
  json.number_of_players table.number_of_players
  json.pot_prize table.expending_coins # TODO: renombrar esto
  json.start_time table.start_time.strftime('%d/%m/%Y - %H:%M')
  json.end_time table.end_time.strftime('%d/%m/%Y - %H:%M')
  json.description table.description
  json.has_been_played_by_user table.has_played?(current_user)
  json.multiplier table.multiplier_for(current_user)
  json.tournament_id  table.tournament_id
  json.private table.private?
  json.amount_of_users_playing table.amount_of_users_playing

  if table.private?
    json.group do
      json.name table.group.name
      json.size table.group.size
    end
  end
end

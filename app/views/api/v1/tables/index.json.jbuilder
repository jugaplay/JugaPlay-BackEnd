json.array! @tables do |table|
  json.id table.id
  json.title table.title
  json.has_password false # TODO: sacar esto
  json.entry_coins_cost table.entry_coins_cost
  json.number_of_players table.number_of_players
  json.pot_prize table.expending_coins # TODO: renombrar esto
  json.start_time table.start_time.strftime('%d/%m/%Y - %H:%M')
  json.end_time table.end_time.strftime('%d/%m/%Y - %H:%M')
  json.description table.description
  json.has_been_played_by_user !table.did_not_play?(current_user)
  json.tournament_id  table.tournament_id
  json.private table.private?
  json.amount_of_users_playing table.amount_of_users_playing
end

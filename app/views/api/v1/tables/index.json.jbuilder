json.array! @tables do |table|
  json.id table.id
  json.title table.title
  json.has_password table.has_password
  json.entry_coins_cost table.entry_coins_cost
  json.number_of_players table.number_of_players
  json.start_time table.start_time.strftime('%d/%m/%Y - %H:%M')
  json.end_time table.end_time.strftime('%d/%m/%Y - %H:%M')
  json.description table.description
  json.has_been_played_by_user !table.can_play_user?(current_user)
  json.tournament_id  table.tournament_id
end

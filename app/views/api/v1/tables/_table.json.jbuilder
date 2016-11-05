json.id table.id
json.title table.title
json.has_password false # TODO: sacar esto
json.number_of_players table.number_of_players
json.entry_coins_cost table.entry_coins_cost
json.tournament_id  table.tournament_id
json.start_time table.start_time.strftime('%d/%m/%Y - %H:%M')
json.end_time table.end_time.strftime('%d/%m/%Y - %H:%M')
json.description table.description
json.private table.private?
json.amount_of_users_playing table.amount_of_users_playing

json.coins_for_winners(table.coins_with_positions) do |coins_with_position|
  json.position coins_with_position.first
  json.coins coins_with_position.second
end

unless table.closed?
  json.playing(table.plays) do |play|
    json.user_id play.user.id
    json.user_mail play.user.email
    json.nickname play.user.nickname
    if play.user.rankings.first.present?
      json.ranking_tournament_points play.user.rankings.first.points
      json.ranking_tournament_position play.user.rankings.first.position
    end
    json.players(play.players) do |player|
      json.player_id player.id
    end
  end
end

if table.private?
  json.group do
    json.partial! partial: 'api/v1/groups/group', locals: { group: table.group }
  end
end

json.winners(table.winners) do |winner|
  json.user_id winner.user_id
  json.user_email winner.user.email
  json.nickname winner.user.nickname
  json.bet_coins winner.user.bet_coins_in_table(table) { 0 }
  json.position winner.position
  json.points table.points_for_winners[winner.position - 1]
end

json.matches do
  json.partial! partial: 'api/v1/matches/match', collection: table.matches, as: :match
end

json.table_rules do
  json.partial! partial: 'api/v1/tables_rules/table_rules', locals: { table_rules: table.table_rules }
end

json.id table.id
json.title table.title
json.has_password false # TODO: sacar esto
json.number_of_players table.number_of_players
json.entry_cost_value table.entry_cost.value
json.entry_cost_type table.entry_cost.currency
json.multiplier_chips_cost table.multiplier_chips_cost
json.tournament_id  table.tournament_id
json.start_time table.start_time.strftime('%d/%m/%Y - %H:%M')
json.end_time table.end_time.strftime('%d/%m/%Y - %H:%M')
json.description table.description
json.private table.private?
json.amount_of_users_playing table.amount_of_users_playing

json.prizes(table.prizes_with_positions) do |prize_with_position|
  json.position prize_with_position.first
  json.prize_value prize_with_position.second.value
  json.prize_type prize_with_position.second.currency
end

unless table.closed?
  json.playing(table.plays_for_user(current_user)) do |play|
    json.type play.type
    json.user_id play.user.id
    json.user_mail play.user.email
    json.nickname play.user.nickname
    json.multiplier play.multiplier
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

json.winners(table.table_rankings_for_user(current_user)) do |table_ranking|
  json.user_id table_ranking.user.id
  json.user_email table_ranking.user.email
  json.nickname table_ranking.user.nickname
  json.cost_value table_ranking.play_cost.value
  json.cost_type table_ranking.play_cost.currency
  json.position table_ranking.position
  json.points table_ranking.points
end

json.matches do
  json.partial! partial: 'api/v1/matches/match', collection: table.matches, as: :match
end

json.table_rules do
  json.partial! partial: 'api/v1/tables_rules/table_rules', locals: { table_rules: table.table_rules }
end

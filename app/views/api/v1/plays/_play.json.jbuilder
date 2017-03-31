json.id play.id
json.start_time play.table.start_time
json.bet_coins play.bet_coins
json.points play.points { 'N/A' }
json.earn_coins play.earned_coins

json.players(play.players) do |player|
  json.id player.id
  json.first_name player.first_name
  json.last_name player.last_name
  json.team player.team_name_if_none { 'N/A' }
  json.team_id player.team_id { 'N/A' }
  json.points PlayerPointsCalculator.new.call(play.table, player) unless play.table.opened?
end

json.table do
  json.id play.table_id
  json.title play.table.title
  json.position play.position
  json.payed_points play.points_for_ranking
  json.group_name play.table.group.name if play.private?
end

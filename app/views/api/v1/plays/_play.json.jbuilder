json.id play.id
json.start_time play.table.start_time
json.cost_value play.cost.value
json.cost_type play.cost.currency
json.multiplier play.multiplier
json.points play.points { 'N/A' }
json.prize_type play.prize_currency
json.prize_value play.prize_value

# POR RETROCOMPATIBILIDAD #
json.bet_base_coins play.cost_value
json.bet_multiplier play.multiplier
json.earn_coins (play.prize.try(:coins?) ? play.prize_value : 0)
###########################

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

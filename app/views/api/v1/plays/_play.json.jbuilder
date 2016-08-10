json.id play.id
json.start_time play.table.start_time
json.points (play.points || 'N/A')
json.bet_coins play.bet_coins

play.table.prizes do |prize|

	if prize.t_prize.user_id = @current_user.id
		json.earn_coins prize.t_prize.coins
	end
	
end

json.players(play.players) do |player|
  json.id player.id
  json.first_name player.first_name
  json.last_name player.last_name
  json.team player.team_name_if_none { 'N/A' }
  json.team_id player.team_id { 'N/A' }
  json.points PlayPointsCalculator.new.call_for_player(play, player) unless play.table.opened?
end

json.table do
  json.id play.table_id
  json.title play.table.title
  json.position play.table.position(play.user) { 'N/A' }
  json.payed_points play.table.payed_points(play.user) { 'N/A' }
end

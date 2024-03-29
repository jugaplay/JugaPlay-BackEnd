json.position league_ranking.position
json.user_id league_ranking.user.id
json.nickname league_ranking.user.nickname
json.movement league_ranking.movement
json.points_acumulative league_ranking.total_points

json.rounds(league_ranking.all_rankings) do |old_ranking|
  json.user_position old_ranking.position
  json.movement old_ranking.movement
  json.points_of_round old_ranking.round_points
  json.round old_ranking.round
  json.round_status old_ranking.status

  json.tables(old_ranking.best_plays) do |play|
    json.table_id play.table.id
    json.table_name play.table.title
    json.points play.points { 'N/A' }
  end
end

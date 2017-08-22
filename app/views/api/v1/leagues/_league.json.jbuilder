json.id league.id
json.starts league.starts_at.strftime('%d/%m/%Y - %H:%M')
json.ends league.ends_at.strftime('%d/%m/%Y - %H:%M')
json.frequency league.frequency_in_days
json.amount_of_matches LeagueRanking::AMOUNT_OF_PLAYS_FOR_RANKING
json.users_playing league.amount_of_rankings
json.status league.status_cd

json.prizes(league.prizes_with_positions) do |prize_with_position|
  json.position prize_with_position.first
  json.prize_type prize_with_position.second.currency
  json.prize_value prize_with_position.second.value
end

json.user_league do
  ranking = league.ranking_for_user(current_user)
  json.user_position (ranking.try(:position) || 'N/A')
  json.points_acumulative (ranking.try(:total_points) || 'N/A')
end

json.league_data do
  json.partial! partial: 'api/v1/leagues/league', locals: { league: @league }
end

json.league_rankings do
  json.partial! partial: 'api/v1/leagues/league_ranking', collection: @league_rankings, as: :league_ranking
end

json.pagination do
  json.partial! partial: 'api/v1/pagination/info', locals: { model: @league_rankings, total_items: @total_items }
end

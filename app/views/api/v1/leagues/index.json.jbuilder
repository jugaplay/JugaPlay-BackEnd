json.leagues do
  json.partial! partial: 'api/v1/leagues/league', collection: @leagues, as: :league
end

json.pagination do
  json.partial! partial: 'api/v1/pagination/info', locals: { model: @leagues, total_items: @total_items }
end

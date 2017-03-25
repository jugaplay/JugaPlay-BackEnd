json.table_rankings do
  json.partial! partial: 'api/v1/table_rankings/table_ranking', collection: @table_rankings, as: :table_ranking
end

json.pagination do
  json.partial! partial: 'api/v1/pagination/info', locals: { model: @table_rankings, total_items: @total_items }
end

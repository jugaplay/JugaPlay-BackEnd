json.prizes do
  json.partial! partial: 'api/v1/prizes/prize', collection: @prizes, as: :prize
end

json.pagination do
  json.partial! partial: 'api/v1/pagination/info', locals: { model: @prizes, total_items: @total_items }
end

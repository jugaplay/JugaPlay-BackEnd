json.users do
  json.partial! partial: 'api/v1/users/user_public', collection: @users, as: :user
end

json.pagination do
  json.partial! partial: 'api/v1/pagination/info', locals: { model: @users, total_items: @total_items }
end

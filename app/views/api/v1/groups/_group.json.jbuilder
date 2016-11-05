json.id group.id
json.name group.name
json.size group.size
json.users do
  json.partial! partial: 'api/v1/users/user_public', collection: group.users, as: :user
end

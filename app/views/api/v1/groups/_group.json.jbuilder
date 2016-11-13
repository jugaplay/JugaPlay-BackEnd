json.id group.id
json.name group.name
json.size group.size
json.invitation_token group.group_invitation_token.update_if_expired!.token
json.users do
  json.partial! partial: 'api/v1/users/user_public', collection: group.users, as: :user
end

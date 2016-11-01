json.groups do
  json.partial! partial: 'api/v1/groups/group', collection: @groups, as: :group
end

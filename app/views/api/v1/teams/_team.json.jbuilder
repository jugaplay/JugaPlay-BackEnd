json.id team.id
json.name team.name
json.short_name team.short_name
json.director team.director.full_name
json.description team.description
json.players do
  json.partial! partial: 'api/v1/players/player', collection: team.players, as: :player
end

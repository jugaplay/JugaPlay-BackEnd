json.id match.id
json.title match.title
json.datetime match.datetime.strftime('%d/%m/%Y - %H:%M')
json.local_team do
  json.partial! partial: 'api/v1/teams/team', locals: { team: match.local_team }
end
json.visitor_team do
  json.partial! partial: 'api/v1/teams/team', locals: { team: match.visitor_team }
end
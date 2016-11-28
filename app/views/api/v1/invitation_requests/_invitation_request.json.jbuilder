json.id invitation_request.id
json.type invitation_request.type

json.accepted(invitation_request.invitation_acceptances) do |invitation_acceptance|
  json.id invitation_acceptance.id
  json.ip invitation_acceptance.ip
  json.user invitation_acceptance.user
  json.when invitation_acceptance.created_at
end

json.visited(invitation_request.invitation_visits) do |invitation_visit|
  json.id invitation_visit.id
  json.ip invitation_visit.ip
  json.when invitation_visit.created_at
end

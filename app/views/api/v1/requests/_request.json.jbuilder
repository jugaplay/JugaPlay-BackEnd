json.id request.id
json.request_type request.request_type.name

json.invitations(request.invitations) do |invitation|
  json.id invitation.id
  json.guest_user invitation.guest_user
  json.status invitation.invitation_status.name
  json.won_coins invitation.won_coins
  json.created_at invitation.created_at
  json.guest_ip invitation.guest_ip
end

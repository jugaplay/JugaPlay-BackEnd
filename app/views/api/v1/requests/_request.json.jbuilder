json.id request.id
json.request_type request.request_type.name

json.registrations(request.registrations) do |registration|
  json.id registration.id
  json.guest_user registration.guest_user
  json.status registration.registration_status.name
  json.won_coins registration.won_coins
  json.created_at registration.created_at
  json.guest_ip registration.guest_ip
end

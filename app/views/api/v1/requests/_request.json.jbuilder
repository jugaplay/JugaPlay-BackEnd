json.id request.id
json.user_host request.user_host
json.request_type request.request_tipe

json.registrations(request.registrations) do |registration|
  json.id registration.id
  json.guest_user registration.guest_user
  json.status registration.status
  json.won_coins registration.won_coins
  json.created_at registration.created_at
  json.guest_ip registration.guest_ip
end

json.id address_book.id

json.contacts(address_book.contacts) do |user|
  json.user_id user.id
  json.first_name user.first_name
  json.last_name user.last_name
  json.nickname user.nickname
  json.email user.email
  json.member_since user.created_at.strftime('%d/%m/%Y')
end

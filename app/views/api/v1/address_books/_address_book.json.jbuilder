json.id address_book.id

json.contacts(address_book.address_book_contacts) do |contact|
  json.user_id contact.user.id
  json.name contact.user.name
  json.nickname contact.nickname
  json.synched_by_email contact.synched_by_email
  json.synched_by_facebook contact.synched_by_facebook
end

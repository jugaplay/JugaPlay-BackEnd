json.id address_book.id

json.contacts(address_book.address_book_contacts) do |contact|
  json.nickname contact.nickname
  json.synched_by_email contact.synched_by_email
  json.synched_by_facebook contact.synched_by_facebook
  json.user do
    json.partial! partial: 'api/v1/users/user_public', locals: { user: contact.user }
  end
end

class AddressBookSynchronizer
  def initialize address_book
    @address_book = address_book
  end

  def call_with_facebook_ids(facebook_ids)
    return if facebook_ids.empty?
    users = find_users_with_facebook_ids(facebook_ids)
    new_contacts = users.map { |user| new_contact(user, facebook: true) }
    AddressBookContact.import new_contacts
  end

  def call_with_emails_and_phones(contacts)
    return [] if contacts.empty?
    import_by_email_or_phone contacts
    contacts
  end

  private
  attr_reader :address_book

  def import_by_email_or_phone(contacts)
    new_contacts = []
    contacts.clone.each { |contact| find_and_create_new_contact(contact, contacts, new_contacts) }
    AddressBookContact.import new_contacts.uniq
  end

  def find_and_create_new_contact(contact, contacts, new_contacts)
    user = find_user_by_email_or_phone(contact)
    if user.exists?
      user = user.first
      return if new_contacts.any? { |contact| contact.user_id.eql? user.id }
      synched_by_email = user.email.eql?(contact[:email])
      synched_by_phone = user.telephone.eql?(contact[:phone])
      new_contacts << new_contact(user, nickname: contact[:name], email: synched_by_email, phone: synched_by_phone)
      contacts.delete contact
    end
  end

  def find_users_with_facebook_ids(facebook_ids)
    excluding_existing_contacts User.where(facebook_id: facebook_ids)
  end

  def find_user_by_email_or_phone(contact)
    excluding_existing_contacts User.where('email = ? OR telephone = ?', contact[:email], contact[:phone])
  end

  def excluding_existing_contacts(scope)
    scope.where.not(id: existing_contacts_ids).uniq
  end

  def existing_contacts_ids
    address_book.contacts.map(&:id)
  end

  def new_contact(user, nickname: nil, facebook: false, email: false, phone: false)
    AddressBookContact.new(user: user, address_book: address_book, nickname: (nickname || user.nickname), synched_by_facebook: facebook, synched_by_email: email, synched_by_phone: phone)
  end
end

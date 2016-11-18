class ExternalAddressBookSynchronizer
  def initialize user
    @user = user
  end

  def call_with_emails_and_phones(contacts)
    return if contacts.empty?
    import_unsynched_contacts contacts
    remove_synchronized_contacts
  end

  private
  attr_reader :user

  def import_unsynched_contacts(contacts)
    external_contacts = contacts.map do |contact|
      ExternalAddressBookContact.new(user: user, email: contact[:email], phone: contact[:phone], name: contact[:name])
    end
    ExternalAddressBookContact.import external_contacts
  end

  def remove_synchronized_contacts
    synched_emails = address_book.contacts.pluck(:email)
    external_address_book_contacts.where(email: synched_emails).delete_all
    synched_phones = address_book.contacts.pluck(:telephone)
    external_address_book_contacts.where(phone: synched_phones).delete_all
  end

  def address_book
    @address_book ||= user.address_book
  end

  def external_address_book_contacts
    @external_address_book_contacts ||= ExternalAddressBookContact.where(user: user)
  end
end

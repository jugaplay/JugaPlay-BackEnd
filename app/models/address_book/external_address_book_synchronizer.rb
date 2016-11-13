class ExternalAddressBookSynchronizer
  def initialize user
    @user = user
  end

  def call_with_emails(emails)
    return if emails.empty?
    clean_existing_emails(emails)
    add_emails_to_external_address_book(emails)
    remove_synchronized_emails
  end

  def call_with_phones(phones)
    return if phones.empty?
    clean_existing_phones(phones)
    add_phones_to_external_address_book(phones)
    remove_synchronized_phones
  end

  private
  attr_reader :user

  def clean_existing_emails(emails)
    emails - external_address_book_contacts.pluck(:email)
  end

  def clean_existing_phones(phones)
    phones - external_address_book_contacts.pluck(:phone)
  end

  def add_emails_to_external_address_book(emails)
    external_contacts = emails.map { |email| ExternalAddressBookContact.new(user: user, email: email) }
    ExternalAddressBookContact.import external_contacts
  end

  def add_phones_to_external_address_book(phones)
    external_contacts = phones.map { |phone| ExternalAddressBookContact.new(user: user, phone: phone) }
    ExternalAddressBookContact.import external_contacts
  end

  def remove_synchronized_emails
    synched_emails = address_book.contacts.pluck(:email)
    external_address_book_contacts.where(email: synched_emails).delete_all
  end

  def remove_synchronized_phones
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

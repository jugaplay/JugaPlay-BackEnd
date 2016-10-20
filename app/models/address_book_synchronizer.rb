class AddressBookSynchronizer
  def initialize user
    @address_book = user.address_book
  end

  def call_with_facebook_ids(facebook_ids)
    return if facebook_ids.empty?
    contacts = find_users_with_facebook_ids(facebook_ids)
    add_contacts_to_address_book(contacts)
  end

  def call_with_emails(emails)
    return if emails.empty?
    contacts = find_users_with_emails(emails)
    add_contacts_to_address_book(contacts)
  end

  private
  attr_reader :address_book

  def add_contacts_to_address_book(contacts)
    address_book.contacts += contacts
    address_book.save!
  end

  def find_users_with_facebook_ids(facebook_ids)
    excluding_existing_contacts User.where(facebook_id: facebook_ids)
  end

  def find_users_with_emails(emails)
    excluding_existing_contacts User.where(email: emails)
  end

  def excluding_existing_contacts(scope)
    scope.where.not(id: existing_contacts_ids)
  end

  def existing_contacts_ids
    address_book.contacts.map(&:id)
  end
end

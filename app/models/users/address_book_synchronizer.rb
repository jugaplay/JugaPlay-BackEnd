class AddressBookSynchronizer
  def initialize address_book
    @address_book = address_book
  end

  def call_with_facebook_ids(facebook_ids)
    return if facebook_ids.empty?
    users = find_users_with_facebook_ids(facebook_ids)
    add_contacts_to_address_book(users).each(&:synched_by_facebook!)
  end

  def call_with_emails(emails)
    return if emails.empty?
    users = find_users_with_emails(emails)
    add_contacts_to_address_book(users).each(&:synched_by_email!)
  end

  def call_with_phones(phones)
    return if phones.empty?
    users = find_users_with_phones(phones)
    add_contacts_to_address_book(users).each(&:synched_by_phone!)
  end

  private
  attr_reader :address_book

  def add_contacts_to_address_book(users)
    users.map do |user|
      AddressBookContact.create!(user: user, address_book: address_book, nickname: user.name)
    end
  end

  def find_users_with_facebook_ids(facebook_ids)
    excluding_existing_contacts User.where(facebook_id: facebook_ids)
  end

  def find_users_with_emails(emails)
    excluding_existing_contacts User.where(email: emails)
  end

  def find_users_with_phones(phones)
    excluding_existing_contacts User.where(telephone: phones)
  end

  def excluding_existing_contacts(scope)
    scope.where.not(id: existing_contacts_ids)
  end

  def existing_contacts_ids
    address_book.contacts.map(&:id)
  end
end

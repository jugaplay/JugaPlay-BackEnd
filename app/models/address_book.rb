class AddressBook < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :contacts, class_name: 'User' #, join_table: 'address_book_users', association_foreign_key: 'user_id'

  validates :user, presence: true, uniqueness: true
  validate :unique_contacts

  private

  def unique_contacts
    errors[:base] << 'Contact has already been taken' unless contacts.count.eql? contacts.uniq.count
  end
end

class AddressBook < ActiveRecord::Base
  belongs_to :user
  has_many :address_book_contacts
  has_many :contacts, through: :address_book_contacts, source: :user

  validates :user, presence: true, uniqueness: true
end

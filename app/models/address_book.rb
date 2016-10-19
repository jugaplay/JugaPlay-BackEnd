class AddressBook < ActiveRecord::Base
  belongs_to :user
  has_and_belongs_to_many :contacts, class_name: 'User'

  validates :user, presence: true, uniqueness: true
  validate :unique_contacts

  private

  def unique_contacts
    errors[:base] << 'Contact has already been taken' unless contacts.size.eql? contacts.uniq.count
  end
end

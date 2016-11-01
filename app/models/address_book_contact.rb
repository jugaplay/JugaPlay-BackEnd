class AddressBookContact < ActiveRecord::Base
  belongs_to :user
  belongs_to :address_book

  validates :user, presence: true
  validates :nickname, presence: true
  validates :synched_by_email, inclusion: { in: [ true, false ] }
  validates :synched_by_facebook, inclusion: { in: [ true, false ] }
  validates :address_book, presence: true, uniqueness: { scope: [:user] }

  def synched_by_email!
    update_attributes!(synched_by_email: true)
  end

  def synched_by_facebook!
    update_attributes!(synched_by_facebook: true)
  end
end

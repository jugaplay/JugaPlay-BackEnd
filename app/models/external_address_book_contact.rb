class ExternalAddressBookContact < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true, uniqueness: { scope: [:email, :phone] }
end

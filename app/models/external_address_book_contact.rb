class ExternalAddressBookContact < ActiveRecord::Base
  belongs_to :user

  validates :email, uniqueness: { scope: :user }
  validates :phone, uniqueness: { scope: :user }
end

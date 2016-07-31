class TDeposit < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  belongs_to :country
  belongs_to :payment_service
end

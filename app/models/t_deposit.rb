class TDeposit < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  belongs_to :country
  belongs_to :payment_service
  
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :price, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :user, presence: true
  validates :currency, presence: true
  validates :country, presence: true
  validates :payment_service, presence: true
  validates :transaction_id, presence: true
  validates :operator, presence: true
  validates :type, presence: true

  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
    
end

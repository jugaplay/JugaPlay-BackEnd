class TDeposit < ActiveRecord::Base
  belongs_to :user

  validates :user, presence: true
  validates :country, presence: true, inclusion: { in: Country::ALL }
  validates :currency, presence: true, inclusion: { in: Currency::ALL }
  validates :payment_service, presence: true, inclusion: { in: PaymentService::ALL }
  validates :transaction_id, presence: true
  validates :operator, presence: true
  validates :deposit_type, presence: true
  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
  validates :price, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
end

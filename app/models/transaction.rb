class Transaction < ActiveRecord::Base
  belongs_to :user

  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :user, presence: true
end

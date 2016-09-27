class TPrize < ActiveRecord::Base
  belongs_to :user
  belongs_to :prize
  
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :user, presence: true
  validates :prize, presence: true
  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
      
end

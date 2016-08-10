class TPromotion < ActiveRecord::Base
  belongs_to :user
  
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :user, presence: true
  validates :detail, presence: true, length: { maximum: 500 }, allow_blank: false
  validates :promotion_type, presence: true, allow_blank: false
      
      
      
end

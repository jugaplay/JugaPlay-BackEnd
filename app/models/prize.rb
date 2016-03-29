class Prize < ActiveRecord::Base

  belongs_to :table
  
  validates :position, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates :credits, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }

end

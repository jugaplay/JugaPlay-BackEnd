class Prize < ActiveRecord::Base
  belongs_to :table
  has_one :user_prize
  
  validates :position, numericality: { greater_than: 0, allow_nil: false, only_integer: true }
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }
  validates_uniqueness_of :table_id, :scope => [:position]

  def detail
    "Premio en #{table.title}"
  end
end

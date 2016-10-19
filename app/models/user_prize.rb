class UserPrize < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  
  validates :user, presence: true
  validates :table, presence: true, uniqueness: { scope: [:user] }
  validates :coins, numericality: { greater_than_or_equal_to: 0, allow_nil: false, only_integer: true }

  def detail
    "Premio en #{table.title}"
  end

  def comes_from_table?(table)
    table_id.eql? table.id
  end
end

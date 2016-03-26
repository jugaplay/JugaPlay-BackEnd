class TableWinner < ActiveRecord::Base
  belongs_to :table
  belongs_to :user

  validates :table, presence: true
  validates :user, presence: true, uniqueness: { scope: [:table] }
  validates :position, presence: true, uniqueness: { scope: [:table] }, numericality: { only_integer: true, greater_than: 0 }
end
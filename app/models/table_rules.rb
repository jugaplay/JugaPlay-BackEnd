class TableRules < ActiveRecord::Base
  belongs_to :table

  validates :table, presence: true, uniqueness: true
  validates_presence_of PlayerStats::FEATURES
end

class LeagueRanking < ActiveRecord::Base
  belongs_to :user
  belongs_to :league
  has_and_belongs_to_many :plays

  as_enum :status, opened: 1, playing: 2, closed: 3

  validates :user, presence: true
  validates :league, presence: true, uniqueness: { scope: [:user, :round] }
  validates :round_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :round, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
end

class Ranking < ActiveRecord::Base
  belongs_to :user
  belongs_to :tournament

  validates :tournament, presence: true
  validates :user, presence: true, uniqueness: { scope: [:tournament] }
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, uniqueness: { scope: [:tournament] }, numericality: { greater_than: 0, only_integer: true }

  def self.highest_in_tournament(tournament)
    for_tournament(tournament).order(position: :asc).first
  end

  def self.for_tournament(tournament)
    where(tournament: tournament)
  end

  def self.of_user(users)
    where(user: users)
  end
end
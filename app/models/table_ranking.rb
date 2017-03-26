class TableRanking < ActiveRecord::Base
  belongs_to :play
  has_one :user, through: :play
  has_one :table, through: :play

  validates :play, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :earned_coins, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :validate_position_is_unique_per_table

  scope :by_user, -> user { joins(play: :user).where(plays: { user_id: user.id }) }
  scope :recent_first, -> { order(created_at: :desc) }

  def play_points
    play.points
  end

  def bet_coins
    play.bet_coins
  end

  def detail
    "Premio en #{table.title}"
  end

  def has_position?(position)
    self.position.eql? position
  end

  def private?
    table.private?
  end

  private

  def validate_position_is_unique_per_table
    errors.add(:position, 'has already been taken') if table.try(:cant_place_ranking_in_position?, position, self)
  end
end

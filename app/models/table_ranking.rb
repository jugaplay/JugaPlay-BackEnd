class TableRanking < ActiveRecord::Base
  belongs_to :play
  has_one :user, through: :play
  has_one :table, through: :play

  validates :play, presence: true, uniqueness: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :earned_coins, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :by_user, -> user { joins(play: :user).where(plays: { user_id: user.id }) }
  scope :recent_first, -> { order(created_at: :desc) }

  def play_points
    play.points
  end

  def bet_base_coins
    play.bet_base_coins
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
end

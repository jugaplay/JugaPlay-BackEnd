class TableRanking < ActiveRecord::Base
  belongs_to :play
  has_one :user, through: :play
  has_one :table, through: :play

  validates :play, presence: true, uniqueness: true
  validates :prize_type, presence: true, inclusion: { in: Money::CURRENCIES }
  validates :prize_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }

  scope :recent_first, -> { order(created_at: :desc) }
  scope :trainings, -> { joins(:play).merge(Play.trainings) }
  scope :not_trainings, -> { joins(:play).merge(Play.not_trainings) }
  scope :of_play_type, -> type { joins(:play).merge(Play.of_type(type)) }
  scope :by_user, -> user { joins(play: :user).where(plays: { user_id: user.id }) }
  scope :by_user_and_table, -> user, table { joins(play: :user).joins(play: :table).where(plays: { table_id: table.id }).where(plays: { user_id: user.id }) }

  def prize
    Money.new prize_type, prize_value
  end

  def prize=(prize)
    if prize.is_a?(Money)
      self.prize_type = prize.currency
      self.prize_value = prize.value
    else
      errors.add(:prize, 'Given prize must be money')
      fail ActiveRecord::RecordInvalid.new self
    end
  end

  def play_points
    play.points
  end

  def play_cost
    play.cost
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

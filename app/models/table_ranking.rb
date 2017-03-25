class TableRanking < ActiveRecord::Base
  belongs_to :play
  has_one :user, through: :play
  has_one :table, through: :play

  validates :play, presence: true
  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validate :validate_position_is_unique_per_table

  def play_points
    play.points
  end

  def bet_coins
    play.bet_coins
  end

  def earned_coins
    return 0 unless prize.present?
    prize.coins
  end

  def prize
    @prize ||= Prize.find_by(user: user, table: table)
  end

  private

  def validate_position_is_unique_per_table
    if table.present? && table.has_position?(position)
      errors.add(:position, 'has already been taken')
    end
  end
end

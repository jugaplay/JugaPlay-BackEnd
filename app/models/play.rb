class Play < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  has_many :player_selections, -> { order(position: :asc) }, dependent: :destroy
  has_many :players, through: :player_selections
  has_one :table_ranking, dependent: :destroy

  validates :table, presence: true
  validates :user, presence: true, uniqueness: { scope: :table }
  validates :bet_base_coins, presence: true, numericality: { only_integer: true, allow_nil: false, greater_than_or_equal_to: 0 }
  validates :bet_multiplier, numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 2 }

  scope :recent_finished_by, -> user { where(user: user).joins(:table).merge(Table.closed.recent_first) }

  def coins_bet_multiplier
    bet_multiplier || 1
  end

  def bet_multiplier_by(multiplier)
    update_attributes!(bet_multiplier: multiplier)
  end

  def private?
    table.private?
  end

  def points(&if_none_block)
    return_block = if_none_block || -> { nil }
    self[:points] || return_block.call
  end

  def involves_player?(player)
    players.include? player
  end

  def points_for_ranking(&if_none_block)
    ask_table_ranking_for :points, &if_none_block
  end

  def position(&if_none_block)
    ask_table_ranking_for :position, &if_none_block
  end

 	def earned_coins(&if_none_block)
    ask_table_ranking_for :earned_coins, &if_none_block
  end

  private

  def ask_table_ranking_for(message, &if_none_block)
    return table_ranking.send message if table_ranking.present?
    return_block = if_none_block || -> { 'N/A' }
    return_block.call
  end
end

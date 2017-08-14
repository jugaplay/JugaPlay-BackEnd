class Play < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  has_many :player_selections, -> { order(position: :asc) }, dependent: :destroy
  has_many :players, through: :player_selections
  has_one :table_ranking, dependent: :destroy
  has_and_belongs_to_many :league_rankings

  as_enum :type, league: 1, training: 2, challenge: 3

  validates :table, presence: true
  validates :type, presence: true
  validates :user, presence: true, uniqueness: { scope: :table }
  validates :cost_type, presence: true, inclusion: { in: Money::CURRENCIES }
  validates :cost_value, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :multiplier, numericality: { allow_blank: true, only_integer: true, greater_than_or_equal_to: 2 }

  scope :of_type, -> type { where(type_cd: types[type]) }
  scope :not_trainings, -> { where.not(type_cd: types[:training]) }
  scope :recent_finished_by, -> user { where(user: user).joins(:table).merge(Table.closed.recent_first) }

  def cost(&if_none_block)
    return_block = if_none_block || -> { nil }
    return_block.call if cost_value.nil?
    Money.new(cost_type, cost_value)
  end

  def cost=(money)
    self.cost_type = money.currency
    self.cost_value = money.value
  end

  def multiply_by!(multiplier)
    update_attributes!(multiplier: multiplier)
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

 	def prize(&if_none_block)
    ask_table_ranking_for :prize, &if_none_block
  end

 	def prize_currency(&if_none_block)
    ask_table_ranking_for :prize_type, &if_none_block
  end

 	def prize_value(&if_none_block)
    ask_table_ranking_for :prize_value, &if_none_block
  end

  private

  def ask_table_ranking_for(message, &if_none_block)
    return table_ranking.send message if table_ranking.present?
    return_block = if_none_block || -> { 'N/A' }
    return_block.call
  end
end

class Play < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  has_one :table_ranking, dependent: :destroy
  has_and_belongs_to_many :players, unique: true

  validates_presence_of :user, :table, :players
  validates_uniqueness_of :user_id, scope: [:table]
  validates :bet_coins, presence: true, numericality: { only_integer: true, allow_nil: false, greater_than_or_equal_to: 0 }

  scope :recent_finished_by, -> (user) { where(user: user).joins(:table).merge(Table.closed.recent_first) }

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

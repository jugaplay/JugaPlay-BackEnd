class Table < ActiveRecord::Base
  has_many :plays
  has_one :table_rules
  belongs_to :tournament
  has_many :users, through: :plays
  has_many :winners, class_name: 'TableWinner'
  has_and_belongs_to_many :matches

  serialize :points_for_winners

  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true, date: { after: :start_time }
  validates :number_of_players, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :points_for_winners, presence: true
  validates :entry_coins_cost, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: false }
  validates_each_in_array(:points_for_winners) { validates_numericality_of :value, greater_than: 0, only_integer: true, allow_nil: false }
  validate :validate_all_matches_belong_to_tournament

  def can_play_user?(user)
    plays.where(user: user).empty?
  end

  def can_play_with_amount_of_players?(players)
    number_of_players == players.count
  end

  def include_all_players?(players)
    !players.empty? && players.all? do |player|
      matches.any? { |match| match.is_played_by?(player) }
    end
  end

  def include_all_matches?(matches)
    !matches.empty? && matches.all? { |match| self.matches.include? match }
  end

  def closed?
    !opened?
  end

  def payed_points(user, &if_none_block)
    return_block = proc { return if_none_block.call }
    points_for_winners[position(user, &return_block) - 1]
  end

  def position(user, &if_none_block)
    return_block = proc { return if_none_block.call }
    winner(user, &return_block).position
  end

  private

  def winner(user, &return_block)
    winners.detect(return_block) { |winner| winner.user.eql? user }
  end

  def validate_all_matches_belong_to_tournament
    errors.add(:mathes, 'do not belong to given tournament') unless matches.all? { |match| tournament == match.tournament }
  end
end

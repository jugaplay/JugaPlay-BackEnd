class Table < ActiveRecord::Base
  has_many :plays
  has_one :table_rules
  belongs_to :group
  belongs_to :tournament
  has_many :users, through: :plays
  has_many :winners, class_name: 'TableWinner'
  has_and_belongs_to_many :matches

  serialize :coins_for_winners, Array
  serialize :points_for_winners, Array

  validates :title, presence: true
  validates :description, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true, date: { after: :start_time }
  validates :number_of_players, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :entry_coins_cost, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: true, allow_nil: false }
  validates_each_in_array(:coins_for_winners) { validates_numericality_of :value, greater_than: 0, only_integer: true, allow_nil: false }
  validates_each_in_array(:points_for_winners) { validates_numericality_of :value, greater_than: 0, only_integer: true, allow_nil: false }
  validate :validate_all_matches_belong_to_tournament
  validate :validate_points_for_winners_if_public

  scope :closed, -> { where(opened: false) }
  scope :opened, -> { where(opened: true) }
  scope :publics, -> { where(group_id: nil) }
  scope :privates_for, -> user { joins(group: :groups_users).where(groups_users: { user_id: user.id }).uniq }
  scope :recent_first, -> { order(start_time: :desc) }

  def expending_coins
    coins_for_winners.sum
  end

  def closed?
    !opened?
  end

  def close!
    update_attributes(opened: false)
  end

  def private?
    group.present?
  end

  def public?
    group.nil?
  end

  def amount_of_users_playing
    plays.count
  end

  def can_play?(user)
    public? || (private? && group.has_user?(user))
  end

  def did_not_play?(user)
    plays.where(user: user).empty?
  end

  def coins_with_positions
    coins_for_winners.map.with_index { |coins, index| [index + 1, coins] }
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
    errors.add(:matches, 'do not belong to given tournament') unless matches.all? { |match| tournament == match.tournament }
  end

  def validate_points_for_winners_if_public
    errors.add(:points_for_winners, "can't be blank") if public? && points_for_winners.empty?
  end
end

class Table < ActiveRecord::Base
  has_many :plays
  has_one :table_rules
  belongs_to :group
  belongs_to :tournament
  has_many :users, through: :plays
  has_many :player_selections, through: :plays
  has_many :table_rankings, -> { order(position: :asc) }, through: :plays
  has_and_belongs_to_many :matches

  serialize :prizes_values, Array
  serialize :points_for_winners, Array
  as_enum :status, opened: 1, being_closed: 2, closed: 3

  validates :title, presence: true
  validates :status, presence: true
  validates :description, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true, date: { after: :start_time }
  validates :number_of_players, presence: true, numericality: { greater_than: 0, only_integer: true }
  validates :entry_cost_type, presence: true, inclusion: { in: Money::CURRENCIES }
  validates :entry_cost_value, presence: true, numericality: { greater_than_or_equal_to: 0, allow_nil: false }
  validates :multiplier_chips_cost, presence: true, numericality: { greater_than_or_equal_to: 0, only_integer: false, allow_nil: false }
  validates :prizes_type, presence: true, inclusion: { in: Money::CURRENCIES }
  validates_each_in_array(:prizes_values) { validates_numericality_of :value, greater_than: 0, allow_nil: false }
  validates_each_in_array(:points_for_winners) { validates_numericality_of :value, greater_than: 0, only_integer: true, allow_nil: false }
  validate :validate_all_matches_belong_to_tournament

  scope :opened, -> { openeds }
  scope :closed, -> { closeds }
  scope :being_closed, -> { being_closeds }
  scope :not_closed, -> { where.not(id: closed) }
  scope :with_matches_with_incomplete_stats, -> { joins(:matches).merge(Match.with_incomplete_stats).uniq }
  scope :publics, -> { where(group_id: nil) }
  scope :privates_for, -> user { joins(group: :groups_users).where(groups_users: { user_id: user.id }).uniq }
  scope :recent_first, -> { order(start_time: :desc) }
  scope :closest_first, -> { order(start_time: :asc) }

  def self.can_be_closed
    validator = TableCloserValidator.new
    Table.opened.where('end_time < ?', Time.now - 3.hours).includes(:matches).select do |table|
      begin
        validator.validate_to_start_closing(table)
        true
      rescue TableIsClosed, MissingPlayerStats
        false
      end
    end
  end

  def entry_cost
    Money.new entry_cost_type, entry_cost_value
  end

  def entry_cost=(money)
    if money.is_a?(Money)
      self.entry_cost_type = money.currency
      self.entry_cost_value = money.value
    else
      errors.add(:entry_cost, 'Given entry cost must be money')
      fail ActiveRecord::RecordInvalid.new self
    end
  end

  def prizes
    prizes_values.map { |prize| Money.new prizes_type, prize }
  end

  def prizes=(prizes)
    if prizes.empty?
      self.prizes_type = Money::COINS
      self.prizes_values = []
    elsif prizes.all? { |prize| prize.is_a?(Money) } && prizes.map { |prize| prize.try(:currency) }.uniq.length.eql?(1)
      self.prizes_type = prizes.first.currency
      self.prizes_values = prizes.map(&:value)
    else
      errors.add(:prizes, 'All prizes must be money with same currency')
      fail ActiveRecord::RecordInvalid.new self
    end
  end

  def pot_prize
    Money.new prizes_type, prizes_values.sum
  end

  def open!
    opened!
    save!
  end

  def close!
    closed!
    save!
  end

  def start_closing!
    being_closed!
    save!
  end

  def private?
    group.present?
  end

  def public?
    group.nil?
  end

  def has_rankings?
    !table_rankings.empty?
  end

  def has_points_for_winners?
    !points_for_winners.empty?
  end

  def amount_of_users_playing
    plays.count
  end

  def players
    matches.flat_map(&:players).uniq
  end

  def can_play?(user)
    public? || (private? && group.has_user?(user))
  end

  def has_played?(user)
    !plays_made_by(user).empty?
  end

  def prizes_with_positions
    prizes.map.with_index { |prize, index| [index + 1, prize] }
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

  def points_for_position(position)
    points_for_winners[position - 1] || 0
  end

  def prize_for_position(position)
    prizes[position - 1] || Money.zero(prizes_type)
  end

  def cant_place_ranking_in_position?(position, ranking)
    ranking_in_position = ranking_in_position(position)
    ranking_in_position.present? && !ranking_in_position.eql?(ranking)
  end

  def ranking_in_position(position)
    table_rankings.detect { |ranking| ranking.has_position? position }
  end

  def multiplier_for(user)
    plays_made_by(user).last.try(:multiplier)
  end

  private

  def plays_made_by(user)
    plays.where(user: user)
  end

  def validate_all_matches_belong_to_tournament
    errors.add(:matches, 'do not belong to given tournament') unless matches.all? { |match| tournament == match.tournament }
  end
end

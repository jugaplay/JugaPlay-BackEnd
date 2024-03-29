class Match < ActiveRecord::Base
  belongs_to :tournament
  belongs_to :local_team, class_name: 'Team', foreign_key: 'local_team_id'
  belongs_to :visitor_team, class_name: 'Team', foreign_key: 'visitor_team_id'
  has_and_belongs_to_many :tables

  validates :title, presence: true
  validates :local_team, presence: true
  validates :visitor_team, presence: true
  validates :tournament, presence: true
  validates :datetime, presence: true, uniqueness: { scope: [:local_team, :visitor_team] }
  validate :teams_are_different

  scope :with_incomplete_stats, -> { where(id: (with_incomplete_local_stats.pluck(:id) + with_incomplete_visitor_stats.pluck(:id))).uniq }
  scope :with_incomplete_local_stats, -> { joins(local_team: :players).joins('LEFT JOIN player_stats ON player_stats.player_id = players.id').where('player_stats.id IS NULL').uniq }
  scope :with_incomplete_visitor_stats, -> { joins(visitor_team: :players).joins('LEFT JOIN player_stats ON player_stats.player_id = players.id').where('player_stats.id IS NULL').uniq }

  def self.not_played_yet
    where('datetime >= ?', Date.today)
  end

  def is_played_by?(player)
    local_team.has_player?(player) || visitor_team.has_player?(player)
  end

  def description
    "#{title} #{datetime.strftime('%d/%m/%Y - %H:%M')}"
  end

  def players
    local_team.players + visitor_team.players
  end

  private

  def teams_are_different
    if local_team.present? && visitor_team.present? && local_team.id == visitor_team.id
      errors.add(:visitor_team, 'must be different from local team')
    end
  end
end

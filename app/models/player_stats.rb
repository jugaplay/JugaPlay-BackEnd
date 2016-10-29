class PlayerStats < ActiveRecord::Base
  FEATURES = [
    :shots, :shots_on_goal, :shots_to_the_post, :shots_outside,
    :scored_goals, :goalkeeper_scored_goals, :defender_scored_goals, :free_kick_goal,
    :right_passes, :recoveries, :assists, :undefeated_defense, :wrong_passes,
    :saves, :saved_penalties, :missed_saves, :undefeated_goal,
    :red_cards, :yellow_cards, :offside, :faults, :missed_penalties, :winner_team
  ]

  belongs_to :player
  belongs_to :match

  validates :match, presence: true
  validates :player, presence: true, uniqueness: { scope: [:match] }
  validates_presence_of FEATURES
  validates_numericality_of FEATURES, greater_than_or_equal_to: 0

  def self.for_table(table)
    where(match: table.matches).uniq
  end

  def self.for_player_in_match(player, match)
    find_by(player_id: player.id, match_id: match.id)
  end
end
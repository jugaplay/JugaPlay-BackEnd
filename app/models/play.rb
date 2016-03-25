class Play < ActiveRecord::Base
  belongs_to :user
  belongs_to :table
  has_and_belongs_to_many :players, unique: true

  validates_presence_of :user, :table, :players
  validates_uniqueness_of :user_id, scope: [:table]
  validates :bet_coins, presence: true, numericality: { only_integer: true, allow_nil: false, greater_than_or_equal_to: 0 }

  def involves_player?(player)
    players.include? player
  end
end
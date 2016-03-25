class Team < ActiveRecord::Base
  has_many :players
  belongs_to :director, dependent: :destroy

  accepts_nested_attributes_for :director

  validates :name, presence: true, uniqueness: true
  validates :short_name, presence: true, uniqueness: true
  validates :director, presence: true, uniqueness: true
  validates :description, presence: true

  def has_player?(player)
    players.include? player
  end
end

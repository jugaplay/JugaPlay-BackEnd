class PlayerSelection < ActiveRecord::Base
  belongs_to :play
  belongs_to :player

  validates :play, presence: true
  validates :player, presence: true, uniqueness: { scope: :play }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, uniqueness: { scope: :play }
end

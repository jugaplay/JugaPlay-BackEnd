FactoryGirl.define do
  factory :player_selection do
    play
    player
    position { PlayerSelection.where(play: play).map(&:position).max.to_i + 1 }
    points { 0 }
  end
end

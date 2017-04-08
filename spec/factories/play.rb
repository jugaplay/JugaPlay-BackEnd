FactoryGirl.define do
  factory :play do
    user
    table
    bet_coins { 0 }

    after :build do |play|
      if play.table.present? && play.player_selections.nil?
        players = play.table.matches.sample.local_team.players.sample(play.table.number_of_players)
        create_player_selections(play, players)
      end
    end

    trait :with_players do
      transient do
        players nil
      end

      after :build do |play, evaluator|
        play.player_selections.destroy!
        create_player_selections(play, evaluator.players)
      end
    end
  end
end

def create_player_selections(play, players)
  player_selections = []
  players.each_with_index do |player, index|
    player_selections << PlayerSelection.new(play: play, player: player, position: index + 1, points: 0)
  end
  play.update_attributes(player_selections: player_selections)
end

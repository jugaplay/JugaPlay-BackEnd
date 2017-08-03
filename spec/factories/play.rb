FactoryGirl.define do
  factory :play do
    user
    table
    type { :league }
    cost { 0.coins }

    after :build do |play|
      if play.table.present? && play.player_selections.nil?
        players = play.table.matches.sample.local_team.players.sample(play.table.number_of_players)
        create_player_selections(play, players)
      end
    end

    after :create do |play|
      if play.table.private?
        play.update_attributes!(type: :challenge, cost: play.table.entry_cost)
      elsif play.training?
        play.update_attributes!(cost: Money.zero(play.table.prizes_type))
      else
        play.update_attributes!(cost: play.table.entry_cost)
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

    trait :league do
      transient do
        type nil
      end

      after :build do |play|
        play.type = :league
      end
    end

    trait :training do
      transient do
        type nil
      end

      after :build do |play|
        play.type = :training
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

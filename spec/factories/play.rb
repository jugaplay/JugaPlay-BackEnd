FactoryGirl.define do
  factory :play do
    user
    table
    bet_coins { 0 }

    after(:build) do |play|
      if play.table.present?
        players = play.table.matches.sample.local_team.players.sample(play.table.number_of_players)
        play.update_attributes(players: players)
      end
    end
  end
end

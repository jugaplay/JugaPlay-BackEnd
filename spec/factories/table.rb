FactoryGirl.define do
  factory :table do
    tournament
    title { Faker::Lorem.sentence }
    number_of_players { Faker::Number.between(1, 5) }
    description { Faker::Lorem.sentence }
    points_for_winners { [Faker::Number.number(5), Faker::Number.number(3), Faker::Number.number(2)] }
    entry_coins_cost { 0 }

    after(:build) do |table|
      table.matches = Faker::Number.between(1, 5).times.collect { FactoryGirl.create(:match, tournament: table.tournament) } if table.matches.empty?
      table.start_time = table.matches.map(&:datetime).min
      table.end_time = table.matches.map(&:datetime).max.end_of_day
    end
  end
end

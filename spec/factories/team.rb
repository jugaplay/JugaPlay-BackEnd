FactoryGirl.define do
  factory :team do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    sequence(:short_name) { |n| "#{Faker::Lorem.word}#{n}" }
    description { Faker::Lorem.sentence }
    director

    after(:build) do |team|
      team.players = Faker::Number.between(2, 5).times.collect { FactoryGirl.create(:player, team: team) }
    end

    trait :river do
      name { 'River Plate' }
      after(:create) do |team|
        team.update_attributes(players: [
          FactoryGirl.create(:player, team: team, first_name: 'Fernando', last_name: 'Cavenaghi', position: Position::FORWARD),
          FactoryGirl.create(:player, team: team, first_name: 'Javier', last_name: 'Mascherano', position: Position::MIDFIELDER),
          FactoryGirl.create(:player, team: team, first_name: 'Marcelo', last_name: 'Barovero', position: Position::GOALKEEPER),
        ])
      end
    end

    trait :boca do
      name { 'Boca Juniors' }
      after(:create) do |team|
        team.update_attributes(players: [
          FactoryGirl.create(:player, team: team, first_name: 'Juan Román', last_name: 'Riquelme', position: Position::FORWARD),
          FactoryGirl.create(:player, team: team, first_name: 'Fernando', last_name: 'Gago', position: Position::MIDFIELDER),
          FactoryGirl.create(:player, team: team, first_name: 'Roberto', last_name: 'Abbondanzieri', position: Position::GOALKEEPER),
        ])
      end
    end
  end
end

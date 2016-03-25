FactoryGirl.define do
  factory :match do
    association :tournament, factory: :tournament
    association :local_team, factory: :team
    association :visitor_team, factory: :team
    datetime { DateTime.tomorrow }
    title { Faker::Lorem.sentence }
  end
end

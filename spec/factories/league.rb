FactoryGirl.define do
  factory :league do
    status { :opened }
    frequency_in_days { 7 }
    image { Faker::Internet.url }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.sentence }
    periods { Faker::Number.between(1, 3) }
    prizes { [100.coins, 50.coins, 10.coins] }
  end
end

FactoryGirl.define do
  factory :tournament do
    name { Faker::Lorem.sentence }
  end
end

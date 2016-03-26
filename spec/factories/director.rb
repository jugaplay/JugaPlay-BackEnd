FactoryGirl.define do
  factory :director do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    description { Faker::Lorem.sentence }
  end
end

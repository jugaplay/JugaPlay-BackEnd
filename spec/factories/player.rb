FactoryGirl.define do
  factory :player do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    position { Position::ALL.sample }
    description { Faker::Lorem.sentence }
    nationality { Country::ALL.sample }
    birthday { Faker::Number.between(19, 29).years.ago }
    height { Faker::Number.decimal(2) }
    weight { Faker::Number.decimal(2) }
  end
end

FactoryGirl.define do
  factory :ranking do
    tournament
    user
    position { Faker::Number.number(3) }
    points { Faker::Number.decimal(2) }
  end
end

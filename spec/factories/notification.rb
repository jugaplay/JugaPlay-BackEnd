FactoryGirl.define do
  factory :notification do
    user
    type { NotificationType::ALL.sample }
    title { Faker::Lorem.sentence }
  end
end

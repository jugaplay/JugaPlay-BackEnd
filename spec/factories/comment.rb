FactoryGirl.define do
  factory :comment do
    sender_name { Faker::Lorem.name }
    sender_email { Faker::Internet.email }
    content { Faker::Lorem.sentence }
  end
end

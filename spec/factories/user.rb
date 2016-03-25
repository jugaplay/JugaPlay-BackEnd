FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    nickname { Faker::Internet.user_name }
    password { Faker::Internet.password(8) }

    after :create do |user|
      Wallet.create! user: user
    end

    trait :admin do
      first_name { 'Admin' }
      last_name { 'Admin' }
      email { User::ADMIN_EMAIL }
    end
  end
end

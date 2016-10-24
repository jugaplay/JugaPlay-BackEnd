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

    trait :without_coins do
      after :create do |user|
        user.wallet.update_attributes!(coins: 0)
      end
    end

    trait :admin do
      first_name { 'Admin' }
      last_name { 'Admin' }
      email { User::ADMIN_EMAIL }
    end

    trait :with_an_address_book_with_two_contacts do
      after :create do |user|
        FactoryGirl.create(:address_book, :with_two_contacts, user: user)
      end
    end
  end
end

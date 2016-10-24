FactoryGirl.define do
  factory :address_book do
    user

    trait :with_two_contacts do
      after(:create) do |address_book|
        FactoryGirl.create(:address_book_contact, address_book: address_book)
        FactoryGirl.create(:address_book_contact, address_book: address_book)
      end
    end
  end
end

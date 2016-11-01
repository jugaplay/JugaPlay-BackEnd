FactoryGirl.define do
  factory :address_book_contact do
    user
    address_book
    synched_by_email { true }
    synched_by_facebook { false }
    nickname { Faker::Name.first_name }
  end
end

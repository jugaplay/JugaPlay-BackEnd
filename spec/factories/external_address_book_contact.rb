FactoryGirl.define do
  factory :external_address_book_contact do
    user
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.cell_phone.gsub(/[^0-9]/, '') }
  end
end

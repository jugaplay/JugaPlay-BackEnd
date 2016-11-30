FactoryGirl.define do
  factory :telephone_update_request do
    user
    telephone { Faker::PhoneNumber.cell_phone.gsub(/[^0-9]/, '') }
    validation_code { rand.to_s[2..7] }
  end
end

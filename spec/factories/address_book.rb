FactoryGirl.define do
  factory :address_book do
    user

    after(:create) do |address_book|
      address_book.contacts << FactoryGirl.create(:user)
      address_book.contacts << FactoryGirl.create(:user)
    end
  end
end

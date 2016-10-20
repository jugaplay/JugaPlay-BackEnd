FactoryGirl.define do
  factory :group do
    name { Faker::Name.first_name }

    after :build do |group|
      group.users = [FactoryGirl.create(:user), FactoryGirl.create(:user)] if group.users.empty?
    end
  end
end

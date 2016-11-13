FactoryGirl.define do
  factory :group do
    name { Faker::Name.first_name }

    after :build do |group|
      group.users = [FactoryGirl.create(:user), FactoryGirl.create(:user)] if group.users.empty?
    end

    after :create do |group|
      GroupInvitationToken.create_for_group!(group).update_if_expired!
    end

    trait :with_3_users_without_coins do
      after :build do |group|
        group.users = [FactoryGirl.create(:user, :without_coins), FactoryGirl.create(:user, :without_coins), FactoryGirl.create(:user, :without_coins)]
      end
    end
  end
end

FactoryGirl.define do
  factory :invitation_acceptance do
    user
    invitation_request
    ip { Faker::Internet.ip_v4_address }
  end
end

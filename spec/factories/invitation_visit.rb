FactoryGirl.define do
  factory :invitation_visit do
    invitation_request
    ip { Faker::Internet.ip_v4_address }
  end
end

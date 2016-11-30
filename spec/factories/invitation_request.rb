FactoryGirl.define do
  factory :invitation_request do
    user
    token { Devise.friendly_token(32) }
    type { InvitationRequestType::ALL.sample }

    trait :with_visits_and_acceptances do
      after :create do |invitation_request|
        FactoryGirl.create(:invitation_visit, invitation_request: invitation_request)
        FactoryGirl.create(:invitation_acceptance, invitation_request: invitation_request)
      end
    end
  end
end

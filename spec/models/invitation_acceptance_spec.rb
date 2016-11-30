require 'spec_helper'

describe InvitationAcceptance do
  describe 'validations' do
    it 'must have an invitation request' do
      expect { FactoryGirl.create(:invitation_visit, invitation_request: FactoryGirl.create(:invitation_request)) }.not_to raise_error

      expect { FactoryGirl.create(:invitation_visit, invitation_request: nil) }.to raise_error /Invitation request can't be blank/
    end

    it 'must have a unique user per request' do
      user = FactoryGirl.create(:user)
      request = FactoryGirl.create(:invitation_request)

      expect { FactoryGirl.create(:invitation_acceptance, user: user, invitation_request: request) }.not_to raise_error

      expect { FactoryGirl.create(:invitation_acceptance, user: nil) }.to raise_error /User can't be blank/
      expect { FactoryGirl.create(:invitation_acceptance, user: user, invitation_request: request) }.to raise_error /User has already been taken/
    end

    it 'must have an ip' do
      expect { FactoryGirl.create(:invitation_acceptance, ip: '0.0.0.0') }.not_to raise_error

      expect { FactoryGirl.create(:invitation_acceptance, ip: nil) }.to raise_error /Ip can't be blank/
    end
  end
end

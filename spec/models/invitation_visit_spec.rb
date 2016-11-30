require 'spec_helper'

describe InvitationVisit do
  describe 'validations' do
    it 'must have an invitation request' do
      expect { FactoryGirl.create(:invitation_visit, invitation_request: FactoryGirl.create(:invitation_request)) }.not_to raise_error

      expect { FactoryGirl.create(:invitation_visit, invitation_request: nil) }.to raise_error /Invitation request can't be blank/
    end

    it 'must have an ip' do
      expect { FactoryGirl.create(:invitation_visit, ip: '0.0.0.0') }.not_to raise_error

      expect { FactoryGirl.create(:invitation_visit, ip: nil) }.to raise_error /Ip can't be blank/
    end
  end
end

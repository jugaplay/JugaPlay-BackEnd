require 'spec_helper'

describe InvitationRequest do
  describe 'validations' do
    it 'must have any invitation request type' do
      expect { FactoryGirl.create(:invitation_request, type: InvitationRequestType::WHATSAPP) }.not_to raise_error

      expect { FactoryGirl.create(:invitation_request, type: nil) }.to raise_error /Type can't be blank/
      expect { FactoryGirl.create(:invitation_request, type: '') }.to raise_error /Type can't be blank/
      expect { FactoryGirl.create(:invitation_request, type: 'invalid') }.to raise_error /Type is not included in the list/
    end

    it 'must have a user' do
      expect { FactoryGirl.create(:invitation_request, user: FactoryGirl.create(:user)) }.not_to raise_error

      expect { FactoryGirl.create(:invitation_request, user: nil) }.to raise_error /User can't be blank/
    end

    it 'must have a token of 32 characters' do
      expect { FactoryGirl.create(:invitation_request, token: Devise.friendly_token(32)) }.not_to raise_error

      expect { FactoryGirl.create(:invitation_request, token: nil) }.to raise_error /Token can't be blank/
      expect { FactoryGirl.create(:invitation_request, token: 'a') }.to raise_error /Token is the wrong length/
    end
  end
end

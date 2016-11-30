require 'spec_helper'

describe TelephoneUpdateRequest do
  let(:user) { FactoryGirl.create(:user) }

  describe 'validations' do
    it 'must have a user' do
      expect { FactoryGirl.create(:telephone_update_request, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:telephone_update_request, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must have a telephone as a string with only numbers' do
      expect { FactoryGirl.create(:telephone_update_request, telephone: '541197997394') }.not_to raise_error

      expect { FactoryGirl.create(:telephone_update_request, telephone: nil) }.to raise_error ActiveRecord::RecordInvalid, /Telephone can't be blank/
      expect { FactoryGirl.create(:telephone_update_request, telephone: '+5491182388348') }.to raise_error ActiveRecord::RecordInvalid, /Telephone is invalid/
      expect { FactoryGirl.create(:telephone_update_request, telephone: '54-911-82388348') }.to raise_error ActiveRecord::RecordInvalid, /Telephone is invalid/
      expect { FactoryGirl.create(:telephone_update_request, telephone: '54 911 82388348') }.to raise_error ActiveRecord::RecordInvalid, /Telephone is invalid/
    end

    it 'must have a validation code of six characters unique per user' do
      expect { FactoryGirl.create(:telephone_update_request, validation_code: '123456', user: user) }.not_to raise_error

      expect { FactoryGirl.create(:telephone_update_request, validation_code: nil) }.to raise_error ActiveRecord::RecordInvalid, /Validation code can't be blank/
      expect { FactoryGirl.create(:telephone_update_request, validation_code: '12345') }.to raise_error ActiveRecord::RecordInvalid, /Validation code is the wrong length/
      expect { FactoryGirl.create(:telephone_update_request, validation_code: '1234567') }.to raise_error ActiveRecord::RecordInvalid, /Validation code is the wrong length/
      expect { FactoryGirl.create(:telephone_update_request, validation_code: '123456', user: user) }.to raise_error ActiveRecord::RecordInvalid, /Validation code has already been taken/
    end
  end

  describe '#apply!' do
    let(:request) { FactoryGirl.create(:telephone_update_request) }

    it 'updates the user telephone and marks itself as applied' do
      request.apply!

      expect(request.user.telephone).to eq request.telephone
      expect(request).to be_applied
    end
  end
end

require 'spec_helper'

describe AddressBook do
  describe 'validations' do
    it 'must have a user' do
      user = FactoryGirl.create(:user)

      expect { FactoryGirl.create(:address_book, user: user) }.not_to raise_error
      expect { FactoryGirl.create(:address_book, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
      expect { FactoryGirl.create(:address_book, user: user) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end
  end
end

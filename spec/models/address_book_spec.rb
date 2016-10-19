require 'spec_helper'

describe AddressBook do
  describe 'validations' do
    it 'must have a user' do
      user = FactoryGirl.create(:user)

      expect { FactoryGirl.create(:address_book, user: user) }.not_to raise_error
      expect { FactoryGirl.create(:address_book, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
      expect { FactoryGirl.create(:address_book, user: user) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end

    it 'can a list of contacts without duplication' do
      first_contact = FactoryGirl.create(:user)
      second_contact = FactoryGirl.create(:user)

      expect { FactoryGirl.create(:address_book, contacts: []) }.not_to raise_error
      expect { FactoryGirl.create(:address_book, contacts: [first_contact, second_contact]) }.not_to raise_error
      expect { FactoryGirl.create(:address_book, contacts: [first_contact, first_contact]) }.to raise_error ActiveRecord::RecordInvalid, /Contact has already been taken/
    end
  end
end

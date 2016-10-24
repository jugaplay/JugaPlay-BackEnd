require 'spec_helper'

describe AddressBook do
  describe 'validations' do
    it 'must belong to a user' do
      user = FactoryGirl.create(:user)

      expect { FactoryGirl.create(:address_book_contact, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:address_book_contact, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'must belong to an address book that must be unique for the given user' do
      user = FactoryGirl.create(:user)
      address_book = FactoryGirl.create(:address_book)

      expect { FactoryGirl.create(:address_book_contact, address_book: address_book, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:address_book_contact, address_book: nil) }.to raise_error ActiveRecord::RecordInvalid, /Address book can't be blank/
      expect { FactoryGirl.create(:address_book_contact, address_book: address_book, user: user) }.to raise_error ActiveRecord::RecordInvalid, /Address book has already been taken/
    end

    it 'must know if it was synched by facebook or email' do
      expect { FactoryGirl.create(:address_book_contact, synched_by_email: true) }.not_to raise_error
      expect { FactoryGirl.create(:address_book_contact, synched_by_facebook: false) }.not_to raise_error

      expect { FactoryGirl.create(:address_book_contact, synched_by_email: nil) }.to raise_error ActiveRecord::RecordInvalid, /Synched by email is not included in the list/
      expect { FactoryGirl.create(:address_book_contact, synched_by_facebook: nil) }.to raise_error ActiveRecord::RecordInvalid, /Synched by facebook is not included in the list/
    end
  end
end

require 'spec_helper'

describe AddressBook do
  describe 'validations' do
    it 'must belong to a user' do
      user = FactoryGirl.create(:user)

      expect { FactoryGirl.create(:external_address_book_contact, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:external_address_book_contact, user: nil) }.to raise_error ActiveRecord::RecordInvalid, /User can't be blank/
    end

    it 'can have an email or phone' do
      user = FactoryGirl.create(:user)
      email = 'user@jugaplay.com'
      phone = '12345678'

      expect { FactoryGirl.create(:external_address_book_contact, email: email) }.not_to raise_error
      expect { FactoryGirl.create(:external_address_book_contact, phone: phone) }.not_to raise_error
      expect { FactoryGirl.create(:external_address_book_contact, email: email, phone: phone) }.not_to raise_error
      expect { FactoryGirl.create(:external_address_book_contact, email: email, phone: phone, user: user) }.not_to raise_error

      expect { FactoryGirl.create(:external_address_book_contact, email: email, phone: phone, user: user) }.to raise_error ActiveRecord::RecordInvalid, /User has already been taken/
    end
  end
end

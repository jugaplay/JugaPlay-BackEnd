require 'spec_helper'

describe ExternalAddressBookSynchronizer do
  let(:user) { FactoryGirl.create(:user, :with_an_address_book_with_two_contacts) }
  let(:external_address_book) { ExternalAddressBookContact.where(user: user) }
  let(:synchronizer) { ExternalAddressBookSynchronizer.new(user) }

  describe '#call_with_emails_and_phones' do
    describe 'when no contacts are given' do
      let(:contacts) { [] }

      it 'does not update the address book of the given user' do
        synchronizer.call_with_emails_and_phones(contacts)

        expect(external_address_book).to be_empty
      end
    end

    describe 'when 3 contacts are given' do
      let(:contacts) do
        [
          { name: 'Tom', email: Faker::Internet.email },
          { name: 'Car', phone: '8761234691' },
          { name: 'Bob', email: Faker::Internet.email, phone: '61292392398' },
        ]
      end

      context 'when non of the 3 contacts are in the user address book' do
        it 'updates the external address book of the given user with those emails' do
          synchronizer.call_with_emails_and_phones(contacts)

          expect(external_address_book).to have(3).items

          expect(external_address_book.first.name).to eq contacts.first[:name]
          expect(external_address_book.first.email).to eq contacts.first[:email]
          expect(external_address_book.first.phone).to be_nil

          expect(external_address_book.second.name).to eq contacts.second[:name]
          expect(external_address_book.second.phone).to eq contacts.second[:phone]
          expect(external_address_book.second.email).to be_nil

          expect(external_address_book.third.name).to eq contacts.third[:name]
          expect(external_address_book.third.email).to eq contacts.third[:email]
          expect(external_address_book.third.phone).to eq contacts.third[:phone]
        end
      end

      context 'when one of the 3 contacts is included in the address book' do
        it 'updates the external address book adding just the non-included user' do
          another_user = FactoryGirl.create(:user, email: contacts.first[:email])
          AddressBookContact.create!(address_book: user.address_book, user: another_user, nickname: another_user.name, synched_by_email: true)

          synchronizer.call_with_emails_and_phones(contacts)

          expect(external_address_book).to have(2).item

          expect(external_address_book.first.name).to eq contacts.second[:name]
          expect(external_address_book.first.phone).to eq contacts.second[:phone]
          expect(external_address_book.first.email).to be_nil

          expect(external_address_book.second.name).to eq contacts.third[:name]
          expect(external_address_book.second.email).to eq contacts.third[:email]
          expect(external_address_book.second.phone).to eq contacts.third[:phone]
        end
      end
    end
  end
end

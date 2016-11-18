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

    describe 'when 2 contacts are given' do
      let(:contacts) do
        [
          { name: 'Tom', email: Faker::Internet.email, phone: '54812621323' },
          { name: 'Bob', email: Faker::Internet.email, phone: '61292392398' },
        ]
      end

      context 'when non of the 2 contacts are in the user address book' do
        it 'updates the external address book of the given user with those emails' do
          synchronizer.call_with_emails_and_phones(contacts)

          expect(external_address_book).to have(2).items

          expect(external_address_book.first.user).to eq user
          expect(external_address_book.first.name).to eq contacts.first[:name]
          expect(external_address_book.first.email).to eq contacts.first[:email]
          expect(external_address_book.first.phone).to eq contacts.first[:phone]

          expect(external_address_book.second.user).to eq user
          expect(external_address_book.second.name).to eq contacts.second[:name]
          expect(external_address_book.second.email).to eq contacts.second[:email]
          expect(external_address_book.second.phone).to eq contacts.second[:phone]
        end
      end

      context 'when one of the 2 contacts is included in the address book' do
        it 'updates the external address book adding just the non-included user' do
          another_user = FactoryGirl.create(:user, email: contacts.first[:email])
          AddressBookContact.create!(address_book: user.address_book, user: another_user, nickname: another_user.name, synched_by_email: true)

          synchronizer.call_with_emails_and_phones(contacts)

          expect(external_address_book).to have(1).item
          expect(external_address_book.first.name).to eq contacts.second[:name]
          expect(external_address_book.first.email).to eq contacts.second[:email]
          expect(external_address_book.first.phone).to eq contacts.second[:phone]
        end
      end
    end
  end
end

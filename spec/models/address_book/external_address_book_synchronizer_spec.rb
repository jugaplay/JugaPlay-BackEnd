require 'spec_helper'

describe ExternalAddressBookSynchronizer do
  let(:user) { FactoryGirl.create(:user, :with_an_address_book_with_two_contacts) }
  let(:external_address_book) { ExternalAddressBookContact.where(user: user) }
  let(:synchronizer) { ExternalAddressBookSynchronizer.new(user) }

  describe '#call_with_emails' do
    describe 'when no emails are given' do
      let(:emails) { [] }

      it 'does not update the address book of the given user' do
        synchronizer.call_with_emails(emails)

        expect(external_address_book).to be_empty
      end
    end

    describe 'when 2 emails are given' do
      let(:emails) { [Faker::Internet.email, Faker::Internet.email] }

      context 'when non of the 2 emails are in the user address book' do
        it 'updates the external address book of the given user with those emails' do
          synchronizer.call_with_emails(emails)

          expect(external_address_book).to have(2).items
          expect(external_address_book.first.user).to eq user
          expect(external_address_book.first.email).to eq emails.first
          expect(external_address_book.first.phone).to be_nil
          expect(external_address_book.second.user).to eq user
          expect(external_address_book.second.email).to eq emails.second
          expect(external_address_book.second.phone).to be_nil
        end
      end

      context 'when one of the 2 emails is included in the address book' do
        it 'updates the external address book adding just the non-included user' do
          another_user = FactoryGirl.create(:user, email: emails.first)
          AddressBookContact.create!(address_book: user.address_book, user: another_user, nickname: another_user.name, synched_by_email: true)

          synchronizer.call_with_emails(emails)

          expect(external_address_book).to have(1).item
          expect(external_address_book.first.user).to eq user
          expect(external_address_book.first.email).to eq emails.second
          expect(external_address_book.first.phone).to be_nil
        end
      end
    end
  end

  describe '#call_with_phones' do
    describe 'when no phones are given' do
      let(:phones) { [] }

      it 'does not update the address book of the given user' do
        synchronizer.call_with_phones(phones)

        expect(external_address_book).to be_empty
      end
    end

    describe 'when 2 phones are given' do
      let(:phones) { 2.times.map { Faker::PhoneNumber.cell_phone.gsub(/[^0-9]/, '') } }

      context 'when non of the 2 emails are in the user address book' do
        it 'updates the external address book of the given user with those emails' do
          synchronizer.call_with_phones(phones)

          expect(external_address_book).to have(2).items
          expect(external_address_book.first.user).to eq user
          expect(external_address_book.first.email).to be_nil
          expect(external_address_book.first.phone).to eq phones.first
          expect(external_address_book.second.user).to eq user
          expect(external_address_book.second.email).to be_nil
          expect(external_address_book.second.phone).to eq phones.second
        end
      end

      context 'when one of the 2 phones is included in the address book' do
        it 'updates the external address book adding just the non-included user' do
          another_user = FactoryGirl.create(:user, telephone: phones.first)
          AddressBookContact.create!(address_book: user.address_book, user: another_user, nickname: another_user.name, synched_by_phone: true)

          synchronizer.call_with_phones(phones)

          expect(external_address_book).to have(1).item
          expect(external_address_book.first.user).to eq user
          expect(external_address_book.first.email).to be_nil
          expect(external_address_book.first.phone).to eq phones.second
        end
      end
    end
  end
end

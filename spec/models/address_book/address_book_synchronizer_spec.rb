require 'spec_helper'

describe AddressBookSynchronizer do
  let!(:user) { FactoryGirl.create(:user, :with_an_address_book_with_two_contacts) }
  let(:synchronizer) { AddressBookSynchronizer.new(user.address_book) }

  let!(:unsynched_users) { 10.times.map { |i| FactoryGirl.create(:user, facebook_id: "FB_#{i}", facebook_token: "FB_#{i}", email: "user_#{i}@jugaplay.com") }}

  describe '#call_with_facebook_ids' do
    describe 'when no facebook ids are given' do
      let(:facebook_ids) { [] }

      it 'does not update the address book of the given user' do
        synchronizer.call_with_facebook_ids(facebook_ids)

        expect(user.address_book.contacts).to have(2).items
      end
    end

    describe 'when 3 of 10 facebook ids are given' do
      let(:facebook_ids) { unsynched_users.first(3).map(&:facebook_id) }

      context 'when non of the 3 users are in the address book' do
        it 'updates the address book of the given user with those fb users' do
          synchronizer.call_with_facebook_ids(facebook_ids)

          expect(user.address_book.address_book_contacts).to have(5).items

          first_contact = user.address_book.address_book_contacts.where(user: unsynched_users.first).first
          expect(first_contact.user).to eq unsynched_users.first
          expect(first_contact).to be_synched_by_facebook
          expect(first_contact).not_to be_synched_by_phone
          expect(first_contact).not_to be_synched_by_email
          expect(first_contact.nickname).to eq unsynched_users.first.nickname

          second_contact = user.address_book.address_book_contacts.where(user: unsynched_users.second).first
          expect(second_contact.user).to eq unsynched_users.second
          expect(second_contact).to be_synched_by_facebook
          expect(second_contact).not_to be_synched_by_phone
          expect(second_contact).not_to be_synched_by_email
          expect(second_contact.nickname).to eq unsynched_users.second.nickname

          third_contact = user.address_book.address_book_contacts.where(user: unsynched_users.third).first
          expect(third_contact.user).to eq unsynched_users.third
          expect(third_contact).to be_synched_by_facebook
          expect(third_contact).not_to be_synched_by_phone
          expect(third_contact).not_to be_synched_by_email
          expect(third_contact.nickname).to eq unsynched_users.third.nickname
        end
      end

      context 'when two of the 3 users are in the address book' do
        it 'updates the address book adding just the non-included user' do
          AddressBookContact.create!(address_book: user.address_book, user: unsynched_users.first, nickname: unsynched_users.first.name, synched_by_email: true)
          AddressBookContact.create!(address_book: user.address_book, user: unsynched_users.second, nickname: unsynched_users.second.name, synched_by_facebook: true)

          synchronizer.call_with_facebook_ids(facebook_ids)
          user.address_book.reload

          expect(user.address_book.contacts).to have(5).items
          expect(user.address_book.contacts).to include unsynched_users.first
          expect(user.address_book.contacts).to include unsynched_users.second
          expect(user.address_book.contacts).to include unsynched_users.third
        end
      end
    end

    describe 'when all the facebook ids are given' do
      let(:facebook_ids) { unsynched_users.map(&:facebook_id) }

      it 'updates the address book of the given user with those fb users' do
        synchronizer.call_with_facebook_ids(facebook_ids)
        user.address_book.reload

        expect(unsynched_users - user.address_book.contacts).to be_empty
      end
    end
  end
  
  describe '#call_with_emails_and_phones' do
    describe 'when no contacts are given' do
      let(:contacts) { [] }

      it 'does not update the address book of the given user' do
        synchronizer.call_with_emails_and_phones(contacts)

        expect(user.address_book.contacts).to have(2).items
      end
    end

    describe 'when 3 contacts are given' do
      let(:contacts) do
        [
          { name: 'Tom', email: unsynched_users.first.email, phone: nil },
          { name: 'Bob', email: unsynched_users.second.email, phone: unsynched_users.second.telephone },
          { name: 'Car', email: nil, phone: unsynched_users.third.telephone }
        ]
      end

      context 'when non of the 3 users are in the address book' do
        it 'updates the address book of the given user with those users' do
          expect { synchronizer.call_with_emails_and_phones(contacts) }.to change { AddressBookContact.count }.by 3
          user.address_book.reload

          expect(user.address_book.contacts).to have(5).items

          third_contact = user.address_book.address_book_contacts.third
          expect(third_contact.user).to eq unsynched_users.first
          expect(third_contact.nickname).to eq 'Tom'
          expect(third_contact).to be_synched_by_email
          expect(third_contact).not_to be_synched_by_phone
          expect(third_contact).not_to be_synched_by_facebook

          fourth_contact = user.address_book.address_book_contacts.fourth
          expect(fourth_contact.user).to eq unsynched_users.second
          expect(fourth_contact.nickname).to eq 'Bob'
          expect(fourth_contact).to be_synched_by_email
          expect(fourth_contact).to be_synched_by_phone
          expect(fourth_contact).not_to be_synched_by_facebook

          fifth_contact = user.address_book.address_book_contacts.fifth
          expect(fifth_contact.user).to eq unsynched_users.third
          expect(fifth_contact.nickname).to eq 'Car'
          expect(fifth_contact).not_to be_synched_by_email
          expect(fifth_contact).to be_synched_by_phone
          expect(fifth_contact).not_to be_synched_by_facebook
        end
      end

      context 'when two of the 3 users are in the address book' do
        it 'updates the address book adding just the non-included user' do
          AddressBookContact.create!(address_book: user.address_book, user: unsynched_users.first, nickname: unsynched_users.first.name, synched_by_email: true)
          AddressBookContact.create!(address_book: user.address_book, user: unsynched_users.second, nickname: unsynched_users.second.name, synched_by_facebook: true)

          expect { synchronizer.call_with_emails_and_phones(contacts) }.to change { AddressBookContact.count }.by 1
          user.address_book.reload

          expect(user.address_book.contacts).to have(5).items
          expect(user.address_book.contacts).to include unsynched_users.first
          expect(user.address_book.contacts).to include unsynched_users.second
          expect(user.address_book.contacts).to include unsynched_users.third
        end
      end
    end

    describe 'when 3 contacts are given but there is a duplication' do
      let(:contacts) do
        [
          { name: 'Tom', email: unsynched_users.first.email, phone: nil },
          { name: 'Bob', email: unsynched_users.second.email, phone: unsynched_users.second.telephone },
          { name: 'Tom 2', email: nil, phone: unsynched_users.first.telephone }
        ]
      end

      it 'updates the address book avoiding the duplication' do
        expect { synchronizer.call_with_emails_and_phones(contacts) }.to change { AddressBookContact.count }.by 2
        user.address_book.reload

        expect(user.address_book.contacts).to have(4).items

        third_contact = user.address_book.address_book_contacts.third
        expect(third_contact.user).to eq unsynched_users.first
        expect(third_contact.nickname).to eq 'Tom'
        expect(third_contact).to be_synched_by_email
        expect(third_contact).not_to be_synched_by_phone
        expect(third_contact).not_to be_synched_by_facebook

        fourth_contact = user.address_book.address_book_contacts.fourth
        expect(fourth_contact.user).to eq unsynched_users.second
        expect(fourth_contact.nickname).to eq 'Bob'
        expect(fourth_contact).to be_synched_by_email
        expect(fourth_contact).to be_synched_by_phone
        expect(fourth_contact).not_to be_synched_by_facebook
      end
    end

    describe 'when all the contacts are given' do
      let(:contacts) do
        unsynched_users.map do |user|
          { email: user.email, name: user.nickname, phone: user.telephone }
        end
      end

      it 'updates the address book of the given user with those users' do
        synchronizer.call_with_emails_and_phones(contacts)
        user.address_book.reload

        expect(unsynched_users - user.address_book.contacts).to be_empty
      end
    end
  end
end

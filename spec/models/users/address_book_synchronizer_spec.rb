require 'spec_helper'

describe AddressBookSynchronizer do
  let(:user) { FactoryGirl.create(:user, :with_an_address_book_with_two_contacts) }
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

          third_contact = user.address_book.address_book_contacts.third
          expect(third_contact.user).to eq unsynched_users.first
          expect(third_contact).to be_synched_by_facebook
          expect(third_contact).not_to be_synched_by_email
          expect(third_contact.nickname).to eq unsynched_users.first.name

          fourth_contact = user.address_book.address_book_contacts.fourth
          expect(fourth_contact.user).to eq unsynched_users.second
          expect(fourth_contact).to be_synched_by_facebook
          expect(fourth_contact).not_to be_synched_by_email
          expect(fourth_contact.nickname).to eq unsynched_users.second.name

          fifth_contact = user.address_book.address_book_contacts.fifth
          expect(fifth_contact.user).to eq unsynched_users.third
          expect(fifth_contact).to be_synched_by_facebook
          expect(fifth_contact).not_to be_synched_by_email
          expect(fifth_contact.nickname).to eq unsynched_users.third.name
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
  
  describe '#call_with_email' do
    describe 'when no emails are given' do
      let(:emails) { [] }

      it 'does not update the address book of the given user' do
        synchronizer.call_with_emails(emails)

        expect(user.address_book.contacts).to have(2).items
      end
    end

    describe 'when 3 of 10 emails are given' do
      let(:emails) { unsynched_users.first(3).map(&:email) }

      context 'when non of the 3 users are in the address book' do
        it 'updates the address book of the given user with those users' do
          synchronizer.call_with_emails(emails)
          user.address_book.reload

          expect(user.address_book.contacts).to have(5).items

          third_contact = user.address_book.address_book_contacts.third
          expect(third_contact.user).to eq unsynched_users.first
          expect(third_contact).not_to be_synched_by_facebook
          expect(third_contact).to be_synched_by_email
          expect(third_contact.nickname).to eq unsynched_users.first.name

          fourth_contact = user.address_book.address_book_contacts.fourth
          expect(fourth_contact.user).to eq unsynched_users.second
          expect(fourth_contact).not_to be_synched_by_facebook
          expect(fourth_contact).to be_synched_by_email
          expect(fourth_contact.nickname).to eq unsynched_users.second.name

          fifth_contact = user.address_book.address_book_contacts.fifth
          expect(fifth_contact.user).to eq unsynched_users.third
          expect(fifth_contact).not_to be_synched_by_facebook
          expect(fifth_contact).to be_synched_by_email
          expect(fifth_contact.nickname).to eq unsynched_users.third.name
        end
      end

      context 'when two of the 3 users are in the address book' do
        it 'updates the address book adding just the non-included user' do
          AddressBookContact.create!(address_book: user.address_book, user: unsynched_users.first, nickname: unsynched_users.first.name, synched_by_email: true)
          AddressBookContact.create!(address_book: user.address_book, user: unsynched_users.second, nickname: unsynched_users.second.name, synched_by_facebook: true)

          synchronizer.call_with_emails(emails)
          user.address_book.reload

          expect(user.address_book.contacts).to have(5).items
          expect(user.address_book.contacts).to include unsynched_users.first
          expect(user.address_book.contacts).to include unsynched_users.second
          expect(user.address_book.contacts).to include unsynched_users.third
        end
      end
    end

    describe 'when all the emails are given' do
      let(:emails) { unsynched_users.map(&:email) }

      it 'updates the address book of the given user with those users' do
        synchronizer.call_with_emails(emails)
        user.address_book.reload

        expect(unsynched_users - user.address_book.contacts).to be_empty
      end
    end
  end
end

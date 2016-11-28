require 'spec_helper'

describe Api::V1::AddressBooksController do
  let(:user) { FactoryGirl.create(:user, :with_an_address_book_with_two_contacts) }

  describe 'POST #synch' do
    let!(:unsynched_users) { 10.times.map { |i| FactoryGirl.create(:user, facebook_id: "FB_#{i}", facebook_token: "FB_#{i}", email: "user_#{i}@jugaplay.com") }}
    let(:users_by_email) { unsynched_users.first(2) }
    let(:users_by_phone) { [unsynched_users.fourth, unsynched_users.fifth] }
    let(:users_by_facebook) { unsynched_users.last(2) }
    let(:contacts) do
      users_by_email.map { |user| { name: user.name, email: user.email } } +
      users_by_phone.map { |user| { name: user.name, phone: user.telephone} }
    end

    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has logged in with facebook' do
        before do
          user.update_attributes!(facebook_id: 'facebook_id', facebook_token: 'facebook_token')
          mock_facebook_token_refresh
          mock_facebook_friend_list_with users_by_facebook
        end

        it 'updates the user address book' do
          post :synch, contacts: contacts
          user.address_book.reload

          expect(user.address_book.contacts).to include users_by_email.first
          expect(user.address_book.contacts).to include users_by_email.second
          expect(user.address_book.contacts).to include users_by_phone.first
          expect(user.address_book.contacts).to include users_by_phone.second
          expect(user.address_book.contacts).to include users_by_facebook.first
          expect(user.address_book.contacts).to include users_by_facebook.second

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when the user has not logged in with facebook' do
        it 'updates the user address book' do
          post :synch, contacts: contacts
          user.address_book.reload

          expect(user.address_book.contacts).to include users_by_email.first
          expect(user.address_book.contacts).to include users_by_email.second
          expect(user.address_book.contacts).to include users_by_phone.first
          expect(user.address_book.contacts).to include users_by_phone.second
          expect(user.address_book.contacts).not_to include users_by_facebook.first
          expect(user.address_book.contacts).not_to include users_by_facebook.second

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :synch, contacts: contacts

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'GET #show' do
    context 'when the user is logged in' do
      before { sign_in user }

      it 'responds a json with the information of the address book of the logged in user' do
        get :show

        expect(response).to render_template :show
        expect(response.status).to eq 200

        expect(response_body[:id]).to eq user.address_book.id
        expect(response_body[:contacts]).to have(2).items

        first_contact = user.address_book.address_book_contacts.first
        expect(response_body[:contacts].first[:nickname]).to eq first_contact.nickname
        expect(response_body[:contacts].first[:synched_by_email]).to eq first_contact.synched_by_email
        expect(response_body[:contacts].first[:synched_by_facebook]).to eq first_contact.synched_by_facebook
        expect(response_body[:contacts].first[:user][:id]).to eq first_contact.user.id
        expect(response_body[:contacts].first[:user][:nickname]).to eq first_contact.user.nickname
        expect(response_body[:contacts].first[:user][:first_name]).to eq first_contact.user.first_name
        expect(response_body[:contacts].first[:user][:last_name]).to eq first_contact.user.last_name
        expect(response_body[:contacts].first[:user][:email]).to eq first_contact.user.email
        expect(response_body[:contacts].first[:user][:member_since]).to eq first_contact.user.created_at.strftime('%d/%m/%Y')
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :show

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

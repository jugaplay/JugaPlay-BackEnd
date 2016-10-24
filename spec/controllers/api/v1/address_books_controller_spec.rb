require 'spec_helper'

describe Api::V1::AddressBooksController do
  let(:user) { FactoryGirl.create(:user, :with_facebook_login, :with_an_address_book_with_two_contacts) }

  before { mock_facebook_token_refresh }

  describe 'POST #synch' do
    let(:emails) { unsynched_users.first(2).map(&:email) }
    let!(:unsynched_users) { 10.times.map { |i| FactoryGirl.create(:user, facebook_id: "FB_#{i}", facebook_token: "FB_#{i}", email: "user_#{i}@jugaplay.com") }}

    before do
      FacebookUser = Struct.new(:id)
      facebook_users = unsynched_users.last(2).map { |user| FacebookUser.new(user.facebook_id) }
      allow_any_instance_of(FacebookRequester).to receive(:friends_list).and_return(facebook_users)
    end

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      it 'updates the user address book' do
        users_by_email = unsynched_users.first(2)
        users_by_facebook = unsynched_users.last(2)

        post :synch, emails: emails
        user.address_book.reload

        expect(user.address_book.contacts).to include users_by_email.first
        expect(user.address_book.contacts).to include users_by_email.second
        expect(user.address_book.contacts).to include users_by_facebook.first
        expect(user.address_book.contacts).to include users_by_facebook.second

        expect(response.status).to eq 200
        expect(response).to render_template :show
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :synch, emails: emails

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'GET #show' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }

      it 'responds a json with the information of the address book of the logged in user' do
        get :show

        expect(response).to render_template :show
        expect(response.status).to eq 200

        expect(response_body[:id]).to eq user.address_book.id
        expect(response_body[:contacts]).to have(2).items
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

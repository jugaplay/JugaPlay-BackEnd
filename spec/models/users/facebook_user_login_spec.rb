require 'spec_helper'

describe FacebookUserLogin do
  let(:facebook_login) { FacebookUserLogin.new OmniAuth::AuthHash.new(omniauth_params), query_params }
  let(:query_params) { {} }
  let(:omniauth_params) do
    {
      provider: 'facebook',
      uid: '1234567',
      info: {
        email: 'joe@bloggs.com',
        first_name: 'Joe',
        last_name: 'Bloggs',
        image: 'www.photo.com'
      },
      credentials: {
        token: 'TOKEN',
      }
    }
  end

  context 'when the user does not exists' do
    context 'when the user was not invited' do
      it 'creates a user with the given params' do
        expect { facebook_login.call }.to change { User.count }.by 1

        new_user = User.last
        expect(new_user.facebook_id).to eq '1234567'
        expect(new_user.provider).to eq 'facebook'
        expect(new_user.email).to eq 'joe@bloggs.com'
        expect(new_user.first_name).to eq 'Joe'
        expect(new_user.last_name).to eq 'Bloggs'
        expect(new_user.image).to eq 'www.photo.com'
        expect(new_user.facebook_token).to eq 'TOKEN'
      end
    end

    context 'when the user was invited' do
      let(:inviting_user) { FactoryGirl.create(:user) }
      let(:query_params) { { 'invited_by' => inviting_user.id } }

      it 'creates a user and gives 10 coins to the inviting user' do
        old_amount_of_coins = inviting_user.coins

        expect { facebook_login.call }.to change { User.count }.by 1

        new_user = User.last
        expect(new_user.facebook_id).to eq '1234567'
        expect(new_user.provider).to eq 'facebook'
        expect(new_user.email).to eq 'joe@bloggs.com'
        expect(new_user.first_name).to eq 'Joe'
        expect(new_user.last_name).to eq 'Bloggs'
        expect(new_user.image).to eq 'www.photo.com'
        expect(new_user.facebook_token).to eq 'TOKEN'
        expect(new_user.invited_by).to eq inviting_user
        expect(inviting_user.reload.coins).to eq old_amount_of_coins + 10
      end
    end
  end

  context 'when the email already exists' do
    let!(:user) { FactoryGirl.create(:user, email: 'joe@bloggs.com') }

    context 'when the user was not invited' do
      it 'updates the email, uid, token, provider and image' do
        expect { facebook_login.call }.not_to change { User.count }
        user.reload

        expect(user.facebook_id).to eq '1234567'
        expect(user.provider).to eq 'facebook'
        expect(user.email).to eq 'joe@bloggs.com'
        expect(user.facebook_token).to eq 'TOKEN'
        expect(user.image).to eq 'www.photo.com'

        expect(user.first_name).not_to eq 'Joe'
        expect(user.last_name).not_to eq 'Bloggs'
      end
    end

    context 'when invited params are given' do
      let(:inviting_user) { FactoryGirl.create(:user) }
      let(:query_params) { { 'invited_by' => inviting_user.id } }

      it 'updates the email, token, uid, provider and image, but does not gove coins to the inviting user' do
        old_amount_of_coins = inviting_user.coins

        expect { facebook_login.call }.not_to change { User.count }
        user.reload

        expect(user.facebook_id).to eq '1234567'
        expect(user.provider).to eq 'facebook'
        expect(user.email).to eq 'joe@bloggs.com'
        expect(user.facebook_token).to eq 'TOKEN'
        expect(user.image).to eq 'www.photo.com'

        expect(user.first_name).not_to eq 'Joe'
        expect(user.last_name).not_to eq 'Bloggs'
        expect(user.invited_by).to be_nil

        expect(inviting_user.reload.coins).to eq old_amount_of_coins
      end
    end
  end
end

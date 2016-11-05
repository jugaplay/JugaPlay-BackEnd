require 'spec_helper'

describe Api::V1::UsersController do
  describe 'POST #create' do
    context 'when the user has not been invited by another user' do
      let(:user_params) do
        {
          user: {
            first_name: 'Carlos',
            last_name: 'Perez',
            nickname: 'carlos_perez',
            email: 'carlos_perez@jugaplay.com',
            password: 12345678
          }
        }
      end

      context 'when request succeeds' do
        it 'creates a user and renders a json of it' do
          expect { post :create, user_params }.to change { User.count }.by(1)

          new_user = User.last
          expect(new_user.first_name).to eq user_params[:user][:first_name]
          expect(new_user.last_name).to eq user_params[:user][:last_name]
          expect(new_user.nickname).to eq user_params[:user][:nickname]
          expect(new_user.email).to eq user_params[:user][:email]
          expect(new_user.encrypted_password).to be_present
          expect(new_user.facebook_id).to be_nil
          expect(new_user.image).to be_nil
          expect(new_user.provider).to be_nil
          expect(new_user.wallet).not_to be_nil
          expect(new_user.coins).to be >= 0
          expect(new_user.address_book).not_to be_nil
          expect(new_user.address_book.contacts).to be_empty

          expect(response).to render_template :show
          expect(response.status).to eq 200
          expect(response_body[:id]).to eq new_user.id
          expect(response_body[:nickname]).to eq new_user.nickname
          expect(response_body[:email]).to eq new_user.email
          expect(response_body[:first_name]).to eq new_user.first_name
          expect(response_body[:last_name]).to eq new_user.last_name
          expect(response_body[:member_since]).to eq new_user.created_at.strftime('%d/%m/%Y')
          expect(response_body[:image]).to eq nil
        end

        it 'sends a welcome email' do
          post :create, user_params

          welcome_mails = WelcomeMailer.deliveries
          expect(welcome_mails).to have(1).item
          expect(welcome_mails.last.to).to include user_params[:user][:email]
          expect(welcome_mails.last.from).to include WelcomeMailer::INFO_MAIL
          expect(welcome_mails.last.subject).to eq 'Bienvenido!'
        end

        context 'when facebook information is present' do
          let(:user_params) do
            {
              user: {
                first_name: 'Carlos',
                last_name: 'Perez',
                nickname: 'carlos_perez',
                email: 'carlos_perez@jugaplay.com',
                password: 12345678,
                uid: '2478723649',
                facebook_token: '2asdf4asdf7a8sdf72asadf36asdf4d9',
                image: 'url'
              }
            }
          end

          it 'creates a user and renders a json of it' do
            expect { post :create, user_params }.to change { User.count }.by(1)

            new_user = User.last
            expect(new_user.first_name).to eq user_params[:user][:first_name]
            expect(new_user.last_name).to eq user_params[:user][:last_name]
            expect(new_user.nickname).to eq user_params[:user][:nickname]
            expect(new_user.email).to eq user_params[:user][:email]
            expect(new_user.facebook_id).to eq user_params[:user][:uid]
            expect(new_user.image).to eq user_params[:user][:image]
            expect(new_user.provider).to eq 'facebook'
            expect(new_user.encrypted_password).to be_present

            expect(response).to render_template :show
            expect(response.status).to eq 200
            expect(response_body[:id]).to eq new_user.id
            expect(response_body[:nickname]).to eq new_user.nickname
            expect(response_body[:email]).to eq new_user.email
            expect(response_body[:first_name]).to eq new_user.first_name
            expect(response_body[:last_name]).to eq new_user.last_name
            expect(response_body[:member_since]).to eq new_user.created_at.strftime('%d/%m/%Y')
            expect(response_body[:image]).to eq new_user.image
          end
        end
      end

      context 'when the request fails' do
        context 'when a required parameter is missing' do
          # TODO: Fix this when front-end implements new form
          let(:mandatory_fields) { user_params[:user].except(:nickname).keys }

          it 'does not create a user and renders a json with error messages' do
            mandatory_fields.each do |param|
              missing_params = user_params.deep_dup
              missing_params[:user].delete(param)

              expect { post :create, missing_params }.to_not change { User.count }

              expect(response.status).to eq 200
              expect(response_body[:errors][param]).to include "can't be blank"
            end
          end
        end

        context 'when an email is already taken' do
          before(:each) { post :create, user_params }

          it 'does not create a user and renders a json with error messages' do
            expect { post :create, user_params }.to_not change { User.count }

            expect(response.status).to eq 200
            expect(response_body[:errors][:email]).to include 'has already been taken'
          end
        end

        context 'when a nickname is already taken' do
          before(:each) { post :create, user_params }

          it 'does not create a user and renders a json with error messages' do
            expect { post :create, user_params }.to_not change { User.count }

            expect(response.status).to eq 200
            expect(response_body[:errors][:nickname]).to include 'has already been taken'
          end
        end

        context 'when the password has less than 8 characters' do
          before(:each) { user_params[:user][:password] = 1234567 }

          it 'does not create a user and renders a json with error messages' do
            expect { post :create, user_params }.to_not change { User.count }

            expect(response.status).to eq 200
            expect(response_body[:errors][:password]).to include 'is too short (minimum is 8 characters)'
          end
        end
      end
    end

    context 'when the user has not been invited by another user' do
      let!(:existing_user) { FactoryGirl.create(:user) }
      let(:user_params) do
        {
          user: {
            first_name: 'Carlos',
            last_name: 'Perez',
            nickname: 'carlos_perez',
            email: 'carlos_perez@jugaplay.com',
            password: 12345678,
            invited_by_id: existing_user.id
          }
        }
      end

      context 'when request succeeds' do
        before { NotificationType.create!(name: 'friend-invitation') }

        it 'creates a user, add some coins to the user that has invited him, and renders a json of it' do
          existing_user_initial_coins = existing_user.coins

          expect { post :create, user_params }.to change { User.count }.by(1)

          new_user = User.last
          expect(new_user.first_name).to eq user_params[:user][:first_name]
          expect(new_user.last_name).to eq user_params[:user][:last_name]
          expect(new_user.nickname).to eq user_params[:user][:nickname]
          expect(new_user.email).to eq user_params[:user][:email]
          expect(new_user.encrypted_password).to be_present
          expect(new_user.coins).to be >= 0
          expect(new_user.invited_by).to eq existing_user
          expect(new_user.facebook_id).to be_nil
          expect(new_user.image).to be_nil
          expect(new_user.provider).to be_nil
          expect(existing_user.reload.coins).to eq existing_user_initial_coins + Wallet::COINS_PER_INVITATION

          expect(response).to render_template :show
          expect(response.status).to eq 200
          expect(response_body[:id]).to eq new_user.id
          expect(response_body[:nickname]).to eq new_user.nickname
          expect(response_body[:email]).to eq new_user.email
          expect(response_body[:first_name]).to eq new_user.first_name
          expect(response_body[:last_name]).to eq new_user.last_name
          expect(response_body[:member_since]).to eq new_user.created_at.strftime('%d/%m/%Y')
          expect(response_body[:image]).to eq nil
        end

        it 'sends a welcome email' do
          post :create, user_params

          welcome_mails = WelcomeMailer.deliveries
          expect(welcome_mails).to have(1).item
          expect(welcome_mails.last.to).to include user_params[:user][:email]
          expect(welcome_mails.last.from).to include WelcomeMailer::INFO_MAIL
          expect(welcome_mails.last.subject).to eq 'Bienvenido!'
        end
      end
    end
  end

  describe 'GET #show' do
    let(:user) { FactoryGirl.create(:user) }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the requested id corresponds to the logged in user' do
        it 'responds a json with the information of the logged in user' do
          get :show, id: user.id

          expect(response).to render_template :show
          expect(response.status).to eq 200
          expect(response_body[:id]).to eq user.id
          expect(response_body[:email]).to eq user.email
          expect(response_body[:nickname]).to eq user.nickname
          expect(response_body[:first_name]).to eq user.first_name
          expect(response_body[:last_name]).to eq user.last_name
          expect(response_body[:member_since]).to eq user.created_at.strftime('%d/%m/%Y')
        end
      end

      context 'when the requested id does not correspond to the logged in user' do
        it 'responds a json with the information of the logged in user' do
          get :show, id: (user.id + 10)

          expect(response).to render_template :show
          expect(response.status).to eq 200
          expect(response_body[:id]).to eq user.id
          expect(response_body[:nickname]).to eq user.nickname
          expect(response_body[:email]).to eq user.email
          expect(response_body[:first_name]).to eq user.first_name
          expect(response_body[:last_name]).to eq user.last_name
          expect(response_body[:member_since]).to eq user.created_at.strftime('%d/%m/%Y')
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :show, id: user.id

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let(:user) { FactoryGirl.create(:user) }
    let(:user_params) do
      {
        id: user.id,
        user: {
          first_name: 'Carlos',
          last_name: 'Perez',
          nickname: 'carlos_perez',
          email: 'carlos_perez@jugaplay.com',
          password: 12345678
        }
      }
    end

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when request succeeds' do
        context 'when the given user id corresponds to the logged user' do
          it 'updates the logged user and renders a json of it' do
            patch :update, user_params

            updated_user = user.reload
            expect(updated_user.first_name).to eq user_params[:user][:first_name]
            expect(updated_user.last_name).to eq user_params[:user][:last_name]
            expect(updated_user.nickname).to eq user_params[:user][:nickname]
            expect(updated_user.email).to eq user_params[:user][:email]
            expect(updated_user.encrypted_password).to be_present

            expect(response).to render_template :show
            expect(response.status).to eq 200
            expect(response_body[:id]).to eq updated_user.id
            expect(response_body[:nickname]).to eq updated_user.nickname
            expect(response_body[:email]).to eq updated_user.email
            expect(response_body[:first_name]).to eq updated_user.first_name
            expect(response_body[:last_name]).to eq updated_user.last_name
            expect(response_body[:member_since]).to eq updated_user.created_at.strftime('%d/%m/%Y')
          end
        end

        context 'when the given user id does not correspond to the logged user' do
          before(:each) { user_params[:id] = user.id + 10 }

          it 'updates the logged user and renders a json of it' do
            patch :update, user_params

            updated_user = user.reload
            expect(updated_user.first_name).to eq user_params[:user][:first_name]
            expect(updated_user.last_name).to eq user_params[:user][:last_name]
            expect(updated_user.email).to eq user_params[:user][:email]
            expect(updated_user.nickname).to eq user_params[:user][:nickname]
            expect(updated_user.encrypted_password).to be_present

            expect(response).to render_template :show
            expect(response.status).to eq 200
            expect(response_body[:id]).to eq updated_user.id
            expect(response_body[:email]).to eq updated_user.email
            expect(response_body[:nickname]).to eq updated_user.nickname
            expect(response_body[:first_name]).to eq updated_user.first_name
            expect(response_body[:last_name]).to eq updated_user.last_name
            expect(response_body[:member_since]).to eq updated_user.created_at.strftime('%d/%m/%Y')
          end
        end
      end

      context 'when the request fails' do
        context 'when an email is already taken' do
          let(:another_user) { FactoryGirl.create(:user) }

          before(:each) { user_params[:user][:email] = another_user.email }

          it 'does not update the email of the user and renders a json with error message' do
            patch :update, user_params

            expect(user.email).not_to eq user_params[:user][:email]

            expect(response.status).to eq 200
            expect(response_body[:errors][:email]).to include 'has already been taken'
          end
        end

        context 'when a nickname is already taken' do
          let(:another_user) { FactoryGirl.create(:user) }

          before(:each) { user_params[:user][:nickname] = another_user.nickname }

          it 'does not update the email of the user and renders a json with error message' do
            patch :update, user_params

            expect(user.nickname).not_to eq user_params[:user][:nickname]

            expect(response.status).to eq 200
            expect(response_body[:errors][:nickname]).to include 'has already been taken'
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        patch :update, user_params

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #search' do
    let!(:harvey_specter) { FactoryGirl.create(:user, first_name: 'Harvey', last_name: 'Specter', email: 'harvey_specter@gmail.com', nickname: 'harvey_specter') }
    let!(:mike_ross) { FactoryGirl.create(:user, first_name: 'Mike', last_name: 'Ross', email: 'mike_ross@gmail.com', nickname: 'mike_ross') }
    let!(:louis_litt) { FactoryGirl.create(:user, first_name: 'Louis', last_name: 'Litt', email: 'louis_litt@gmail.com', nickname: 'louis_litt') }
    let!(:rachel_zane) { FactoryGirl.create(:user, first_name: 'Rachel', last_name: 'Zane', email: 'rachel_zane@gmail.com', nickname: 'rachel_zane') }

    context 'when a user is logged in' do
      before(:each) { sign_in harvey_specter }

      context 'when no search params are given' do
        let(:search_params) do
          {
            search: {
              q: nil,
              playing_tournament: nil,
              order_by_ranking: nil,
              order_by_name: nil
            }
          }
        end

        it 'returns all the users' do
          post :search, search_params

          expect(response.status).to eq 200
          expect(response).to render_template :index
          expect(response_body[:users]).to have(4).items

          expect(response_body[:pagination][:items_per_page]).to eq 25
          expect(response_body[:pagination][:total_items]).to eq 4
          expect(response_body[:pagination][:current_page]).to eq 1
          expect(response_body[:pagination][:total_pages]).to eq 1
        end
      end

      context 'when a tournament is specified' do
        let(:tournament) { FactoryGirl.create(:tournament) }
        let(:another_tournament) { FactoryGirl.create(:tournament) }
        let(:search_params) do
          {
            search: { playing_tournament: tournament, order_by_ranking: true }
          }
        end

        context 'when no user is playing the given tournament' do
          it 'returns an empty list' do
            post :search, search_params

            expect(response.status).to eq 200
            expect(response).to render_template :index
            expect(response_body[:users]).to be_empty
          end
        end

        context 'when two user is playing the given tournament' do
          before do
            FactoryGirl.create(:ranking, tournament: tournament, user: mike_ross, position: 2, points: 5)
            FactoryGirl.create(:ranking, tournament: tournament, user: harvey_specter, position: 1, points: 10)
            FactoryGirl.create(:ranking, tournament: another_tournament, user: rachel_zane, position: 1, points: 10)
          end

          it 'returns both users' do
            post :search, search_params

            expect(response.status).to eq 200
            expect(response).to render_template :index
            expect(response_body[:users]).to have(2).item
            expect(response_body[:users].first[:first_name]).to eq harvey_specter.first_name
            expect(response_body[:users].second[:first_name]).to eq mike_ross.first_name

            expect(response_body[:pagination][:items_per_page]).to eq 25
            expect(response_body[:pagination][:total_items]).to eq 2
            expect(response_body[:pagination][:current_page]).to eq 1
            expect(response_body[:pagination][:total_pages]).to eq 1
          end
        end
      end

      context 'when some query is specified' do
        let(:search_params) do
          {
            search: { q: 'itt' }
          }
        end

        it 'returns the users that match that query by first name, last name, nickname or email' do
          post :search, search_params

          expect(response.status).to eq 200
          expect(response).to render_template :index
          expect(response_body[:users]).to have(1).item
          expect(response_body[:users].first[:first_name]).to eq louis_litt.first_name
        end
      end

      context 'when order by name is requested' do
        let(:search_params) do
          {
            search: { order_by_name: true }
          }
        end

        it 'returns the users sorted by first name and last name' do
          post :search, search_params

          expect(response.status).to eq 200
          expect(response).to render_template :index
          expect(response_body[:users]).to have(4).item
          expect(response_body[:users].first[:first_name]).to eq harvey_specter.first_name
          expect(response_body[:users].second[:first_name]).to eq louis_litt.first_name
          expect(response_body[:users].third[:first_name]).to eq mike_ross.first_name
          expect(response_body[:users].fourth[:first_name]).to eq rachel_zane.first_name

          expect(response_body[:pagination][:items_per_page]).to eq 25
          expect(response_body[:pagination][:total_items]).to eq 4
          expect(response_body[:pagination][:current_page]).to eq 1
          expect(response_body[:pagination][:total_pages]).to eq 1
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :search, {}

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

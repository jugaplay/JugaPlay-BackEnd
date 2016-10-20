require 'spec_helper'

describe Api::V1::GroupsController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'POST #create' do
    let(:first_contact) { FactoryGirl.create(:user) }
    let(:second_contact) { FactoryGirl.create(:user) }
    let(:group_params) { { group: { name: 'Carlos', user_ids: [first_contact.id, second_contact.id] } } }

    context 'when the user is signed in' do
      before { sign_in user }

      context 'when request succeeds' do
        it 'creates a new group with the given data and renders a json of it' do
          expect { post :create, group_params }.to change { Group.count }.by(1)

          new_group = Group.last
          expect(new_group.name).to eq group_params[:group][:name]
          expect(new_group.users).to include first_contact
          expect(new_group.users).to include second_contact

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when the request fails' do
        context 'when no name was given' do
          let(:bad_params) { { group: { user_ids: [first_contact.id, second_contact.id] } } }

          it 'does not create a group and renders a json with error messages' do
            expect { post :create, bad_params }.to_not change { Group.count }

            expect(response.status).to eq 200
            expect(response_body[:errors][:name]).to include "can't be blank"
          end
        end

        context 'when no user ids were given' do
          let(:bad_params) { { group: { name: 'Carlos' } } }

          it 'does not create a group and renders a json with error messages' do
            expect { post :create, bad_params }.to_not change { Group.count }

            expect(response.status).to eq 200
            expect(response_body[:errors][:users]).to include "is too short (minimum is 1 character)"
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :create, group_params

        expect(response.status).to eq 401
        expect(response_body[:error]).to eq 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'GET #show' do
    let(:group) { FactoryGirl.create(:group, users: [user]) }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the logged in user belongs to the requested group' do
        it 'responds a json with the information of the logged in user' do
          get :show, id: group.id

          expect(response_body[:id]).to eq group.id
          expect(response_body[:name]).to eq group.name
          expect(response_body[:users]).to have(group.users.count).items
          expect(response_body[:users].map { |u| u[:id] }).to match_array group.users.map(&:id)

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when the logged in user does not belong to the requested group' do
        it 'responds an error json' do
          get :show, id: FactoryGirl.create(:group).id

          expect(response.status).to eq 200
          expect(response_body[:errors]).to include Api::V1::GroupsController::USER_DOES_NOT_BELONG_TO_GIVEN_GROUP
        end
      end

      context 'when the requested group id does not exist' do
        it 'responds an error json' do
          get :show, id: group.id + 1

          expect(response.status).to eq 422
          expect(response_body[:errors]).to include Api::V1::GroupsController::GROUP_NOT_FOUND
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :show, id: group.id

        expect(response.status).to eq 401
        expect(response_body[:error]).to eq 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    let(:new_user) { FactoryGirl.create(:user) }
    let(:group_params) do
      {
        id: group.id,
        group: { name: 'Perez', user_ids: [new_user.id] }
      }
    end

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when request succeeds' do
        it 'updates the logged user and renders a json of it' do
          patch :update, group_params

          updated_group = group.reload
          expect(updated_group.name).to eq group_params[:group][:name]
          expect(updated_group.users).to have(1).item
          expect(updated_group.users.first).to eq new_user

          expect(response).to render_template :show
          expect(response.status).to eq 200
          expect(response_body[:id]).to eq updated_group.id
          expect(response_body[:name]).to eq updated_group.name
          expect(response_body[:users]).to have(1).item
          expect(response_body[:users].first[:id]).to eq new_user.id
        end
      end

      context 'when the logged in user does not belong to the requested group' do
        it 'responds an error json' do
          params = group_params
          params[:id] = FactoryGirl.create(:group).id

          patch :update, params

          expect(response.status).to eq 200
          expect(response_body[:errors]).to include Api::V1::GroupsController::USER_DOES_NOT_BELONG_TO_GIVEN_GROUP
        end
      end

      context 'when the requested group id does not exist' do
        it 'responds an error json' do
          params = group_params
          params[:id] = group.id + 1

          patch :update, group_params

          expect(response.status).to eq 422
          expect(response_body[:errors]).to include Api::V1::GroupsController::GROUP_NOT_FOUND
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        patch :update, group_params

        expect(response.status).to eq 401
        expect(response_body[:error]).to eq 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

require 'spec_helper'

describe Api::V1::GroupsController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET #show' do
    let(:group) { FactoryGirl.create(:group, users: [user]) }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the logged in user belongs to the requested group' do
        it 'responds a json with the information of the logged in user' do
          get :show, id: group.id
          group.reload

          expect(response_body[:id]).to eq group.id
          expect(response_body[:name]).to eq group.name
          expect(response_body[:invitation_token]).to eq group.invitation_token
          expect(response_body[:users]).to have(group.users.count).items
          expect(response_body[:users].map { |u| u[:id] }).to match_array group.users.map(&:id)

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when the logged in user does not belong to the requested group' do
        it 'responds an error json' do
          get :show, id: FactoryGirl.create(:group).id

          expect(response.status).to eq 400
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
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'GET #index' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the user belongs to some groups' do
        let!(:group) { FactoryGirl.create(:group, users: [user]) }
        let!(:another_group) { FactoryGirl.create(:group, users: [user]) }
        let!(:foreign_group) { FactoryGirl.create(:group) }

        it 'responds a json with the information of the groups of the user' do
          get :index

          expect(response_body[:groups]).to have(2).items
          expect(response.status).to eq 200
          expect(response).to render_template :index
        end
      end

      context 'when the user does not belong to any group' do
        it 'responds a json with the information of the groups of the user' do
          get :index

          expect(response_body[:groups]).to be_empty
          expect(response.status).to eq 200
          expect(response).to render_template :index
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :index

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #create' do
    let(:group_params) { { group: { name: 'Carlos' } } }

    context 'when the user is signed in' do
      before { sign_in user }

      context 'when request succeeds' do
        context 'when no user ids are given' do
          it 'creates a new group including just the logged user and renders a json of it' do
            expect { post :create, group_params }.to change { Group.count }.by(1)

            new_group = Group.last
            expect(new_group.name).to eq group_params[:group][:name]
            expect(new_group.users).to have(1).items
            expect(new_group.users).to include user

            expect(response.status).to eq 200
            expect(response).to render_template :show
          end
        end

        context 'when no user ids are given' do
          it 'creates a new group including the given users and the logged one, and renders a json of it' do
            another_user = FactoryGirl.create(:user)
            params = group_params
            params[:group][:user_ids] = [another_user.id]

            expect { post :create, params }.to change { Group.count }.by(1)

            new_group = Group.last
            expect(new_group.name).to eq group_params[:group][:name]
            expect(new_group.users).to have(2).items
            expect(new_group.users).to match_array [user, another_user]

            expect(response.status).to eq 200
            expect(response).to render_template :show
          end
        end
      end

      context 'when the request fails' do
        context 'when no name was given' do
          let(:bad_params) { { group: { param: 'trash' } } }

          it 'does not create a group and renders a json with error messages' do
            expect { post :create, bad_params }.to_not change { Group.count }

            expect(response.status).to eq 200
            expect(response_body[:errors][:name]).to include "can't be blank"
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :create, group_params

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    let(:group_params) { { id: group.id, group: { name: 'Perez' } } }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when request succeeds' do
        it 'updates the group and renders a json of it' do
          patch :update, group_params

          updated_group = group.reload
          expect(updated_group.name).to eq group_params[:group][:name]
          expect(updated_group.users).to have(1).item
          expect(updated_group.users).to include user

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when request fails' do
        context 'when the requesting user does not belong to the group' do
          it 'responds an error json' do
            params = group_params
            params[:id] = FactoryGirl.create(:group).id

            patch :update, params

            expect(response.status).to eq 400
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
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        patch :update, group_params

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'PUT #add_member' do
    let(:group) { FactoryGirl.create(:group, users: [user]) }
    let(:new_user) { FactoryGirl.create(:user) }
    let(:add_member_params) { { id: group.id, user_id: new_user.id } }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when request succeeds' do
        context 'when the new user does not belong to the group' do
          it 'updates the given group and renders a json of it' do
            put :add_member, add_member_params

            updated_group = group.reload
            expect(updated_group.users).to have(2).item
            expect(updated_group.users).to match_array [user, new_user]

            expect(response.status).to eq 200
            expect(response).to render_template :show
          end
        end

        context 'when the new user already belongs to the group' do
          it 'does not update the given group and renders a json of it' do
            group.update_attributes!(users: [user, new_user])

            put :add_member, add_member_params

            updated_group = group.reload
            expect(updated_group.users).to have(2).item
            expect(updated_group.users).to match_array [user, new_user]

            expect(response.status).to eq 200
            expect(response).to render_template :show
          end
        end
      end

      context 'when request fails' do
        context 'when the logged user does not belong to the requested group' do
          it 'responds an error json' do
            params = add_member_params
            params[:id] = FactoryGirl.create(:group).id

            put :add_member, params

            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::GroupsController::USER_DOES_NOT_BELONG_TO_GIVEN_GROUP
          end
        end

        context 'when the requested group id does not exist' do
          it 'responds an error json' do
            params = add_member_params
            params[:id] = group.id + 1

            put :add_member, params

            expect(response.status).to eq 422
            expect(response_body[:errors]).to include Api::V1::GroupsController::GROUP_NOT_FOUND
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        put :add_member, add_member_params

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #exit' do
    let(:group) { FactoryGirl.create(:group, users: [user]) }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when request succeeds' do
        it 'updates the given group and renders a json of it' do
          post :exit, id: group.id

          updated_group = group.reload
          expect(updated_group.users).to be_empty

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when request fails' do
        context 'when the logged user does not belong to the requested group' do
          it 'responds an error json' do
            post :exit, id: FactoryGirl.create(:group).id

            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::GroupsController::USER_DOES_NOT_BELONG_TO_GIVEN_GROUP
          end
        end

        context 'when the requested group id does not exist' do
          it 'responds an error json' do
            post :exit, id: group.id + 1

            expect(response.status).to eq 422
            expect(response_body[:errors]).to include Api::V1::GroupsController::GROUP_NOT_FOUND
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :exit, id: group.id

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #join' do
    let(:another_user) { FactoryGirl.create(:user) }
    let(:group) { FactoryGirl.create(:group, users: [another_user]) }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when request succeeds' do
        it 'joins the user to the group and renders a json of it' do
          post :join, token: group.invitation_token

          updated_group = group.reload
          expect(updated_group.users).to have(2).item
          expect(updated_group.users).to include user
          expect(updated_group.users).to include another_user

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when request fails' do
        context 'when the token does not match the group token' do
          it 'responds an error json' do
            post :join, token: Devise.friendly_token(32)

            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::GroupsController::INVALID_INVITATION_TOKEN
          end
        end

        context 'when the token is expired' do
          it 'responds an error json' do
            group.group_invitation_token.update_attributes!(expires_at: DateTime.yesterday)

            post :join, token: group.invitation_token

            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::GroupsController::INVALID_INVITATION_TOKEN
          end
        end

        context 'when no token is given' do
          it 'responds an error json' do
            post :join

            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::GroupsController::INVALID_INVITATION_TOKEN
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :join, token: group.invitation_token

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

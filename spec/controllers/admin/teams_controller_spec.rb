require 'spec_helper'

describe Admin::TeamsController do
  let(:admin_user) { FactoryGirl.create(:user, :admin) }

  describe 'GET #index' do
    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :index

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render index view page' do
        get :index

        expect(response).to render_template :index
      end
    end
  end

  describe 'GET #new' do
    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :new

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render new view page' do
        get :new

        expect(response).to render_template :new
      end
    end
  end

  describe 'POST #create' do
    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        post :create

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }
      let(:team_params) do
        {
          team: {
            name: 'River Plate',
            short_name: 'RIV',
            description: 'Millonarios',
            director: {
              first_name: 'Marcelo',
              last_name: 'Gallardo',
              description: '-'
            },
          }
        }
      end

      context 'when request succeeds' do
        it 'should create a new course content with given params and redirect to show view page' do
          expect { post :create, team_params }.to change { Team.count }.by(1)

          new_team = Team.last
          expect(new_team.name).to eq 'River Plate'
          expect(new_team.short_name).to eq 'RIV'
          expect(new_team.description).to eq 'Millonarios'
          expect(new_team.director.full_name).to eq 'Marcelo Gallardo'
          expect(new_team.director.description).to eq '-'
          expect(response).to redirect_to admin_teams_path
        end
      end
    end
  end

  describe 'GET #show' do
    let(:team) { FactoryGirl.create(:team) }

    context 'when admin_user is not logged in' do
      it 'should render show view page' do
        get :show, id: team.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render show view page' do
        get :show, id: team.id

        expect(response).to render_template :show
      end
    end
  end

  describe 'PATCH #update' do
    let(:team) { FactoryGirl.create(:team) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        patch :update, id: team.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should update old team with given params and redirect to show view page' do
        team_params = {
          id: team.id,
          team: {
            name: 'Boca Juniors',
            short_name: 'BOC',
            description: 'Bosteros',
            director: {
              first_name: 'Daniel',
              last_name: 'Perez',
              description: 'bla bla'
            },
          }
        }

        expect { patch :update, team_params }.to change { Team.count }.by(0)

        updated_team = Team.last
        expect(updated_team.name).to eq 'Boca Juniors'
        expect(updated_team.short_name).to eq 'BOC'
        expect(updated_team.description).to eq 'Bosteros'
        expect(updated_team.director.full_name).to eq 'Daniel Perez'
        expect(updated_team.director.description).to eq 'bla bla'
        expect(response).to redirect_to admin_teams_path
      end
    end
  end

  describe 'GET #edit' do
    let(:team) { FactoryGirl.create(:team) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :edit, id: team.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render edit view page' do
        get :edit, id: team.id

        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:team) { FactoryGirl.create(:team) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        delete :destroy, id: team.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should delete given course content and redirect to index path' do
        delete :destroy, id: team.id

        expect{ Team.find team.id }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(response).to redirect_to admin_teams_path
      end
    end
  end
end

require 'spec_helper'

describe Admin::TablesController do
  let!(:admin_user) { FactoryGirl.create(:user, :admin) }
  let!(:tournament) { FactoryGirl.create(:tournament) }
  let(:river) { FactoryGirl.create(:team) }
  let(:boca) { FactoryGirl.create(:team) }
  let(:slo) { FactoryGirl.create(:team) }
  let(:river_boca) { FactoryGirl.create(:match, local_team: river, visitor_team: boca, tournament: tournament) }
  let(:river_slo) { FactoryGirl.create(:match, local_team: river, visitor_team: slo, tournament: tournament) }

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
      let(:table_params) do
        {
          table: {
            title: 'RIV vs SLO',
            number_of_players: 10,
            entry_coins_cost: 20,
            description: 'descripcion',
            tournament_id: tournament.id,
            match_ids: [river_slo.id],
          }
        }
      end

      context 'when request succeeds' do
        it 'should create a new course content with given params and redirect to show view page' do
          expect { post :create, table_params }.to change { Table.count }.by(1)

          new_table = Table.last
          expect(new_table.title).to eq 'RIV vs SLO'
          expect(new_table.number_of_players).to eq 10
          expect(new_table.entry_coins_cost).to eq 20
          expect(new_table.description).to eq 'descripcion'
          expect(new_table.tournament).to eq Tournament.first
          expect(new_table.table_rules).not_to be_nil
          expect(new_table.matches).to include river_slo
          expect(new_table.points_for_winners).to eq PointsForWinners.default
          expect(new_table.coins_for_winners).to be_empty
          expect(response).to redirect_to admin_tables_path
        end
      end
    end
  end

  describe 'GET #show' do
    let(:table) { FactoryGirl.create(:table) }

    context 'when admin_user is not logged in' do
      it 'should render show view page' do
        get :show, id: table.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render show view page' do
        get :show, id: table.id

        expect(response).to render_template :show
      end
    end
  end

  describe 'PATCH #update' do
    let(:table) { FactoryGirl.create(:table, tournament: tournament) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        patch :update, id: table.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should update old table with given params and redirect to show view page' do
        table_params = {
          id: table.id,
          table: {
            title: 'RIV vs BOC',
            number_of_players: 5,
            entry_coins_cost: 10,
            description: 'nueva descripcion',
            match_ids: [river_boca.id],
          }
        }

        expect { patch :update, table_params }.to change { Table.count }.by(0)

        updated_table = Table.last
        expect(updated_table.title).to eq 'RIV vs BOC'
        expect(updated_table.number_of_players).to eq 5
        expect(updated_table.entry_coins_cost).to eq 10
        expect(updated_table.description).to eq 'nueva descripcion'
        expect(updated_table.tournament).to eq Tournament.first
        expect(updated_table.matches).to include river_boca
        expect(response).to redirect_to admin_tables_path
      end
    end
  end

  describe 'GET #edit' do
    let(:table) { FactoryGirl.create(:table) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :edit, id: table.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render edit view page' do
        get :edit, id: table.id

        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:table) { FactoryGirl.create(:table) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        delete :destroy, id: table.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should delete given course content and redirect to index path' do
        delete :destroy, id: table.id

        expect{ Table.find table.id }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(response).to redirect_to admin_tables_path
      end
    end
  end
end

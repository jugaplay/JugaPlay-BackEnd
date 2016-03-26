require 'spec_helper'

describe Admin::PlayersController do
  let!(:admin_user) { FactoryGirl.create(:user, :admin) }
  let!(:river) { FactoryGirl.create(:team) }
  let!(:boca) { FactoryGirl.create(:team) }

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
      let(:player_params) do
        {
          player: { 
            first_name: 'Diego', 
            last_name: 'Rodriguez', 
            position: Position::GOALKEEPER, 
            description: '-', 
            birthday: '1989-6-25',
            nationality: Country::ARGENTINA, 
            weight: 80, 
            height: 1.84,
            team_id: river.id,
          }
        }
      end

      context 'when request succeeds' do
        it 'should create a new course content with given params and redirect to show view page' do
          expect { post :create, player_params }.to change { Player.count }.by(1)

          new_player = Player.last
          expect(new_player.first_name).to eq player_params[:player][:first_name]
          expect(new_player.last_name).to eq player_params[:player][:last_name]
          expect(new_player.position).to eq player_params[:player][:position]
          expect(new_player.description).to eq player_params[:player][:description]
          expect(new_player.birthday).to eq Date.new(1989, 6, 25)
          expect(new_player.nationality).to eq player_params[:player][:nationality]
          expect(new_player.weight).to eq player_params[:player][:weight]
          expect(new_player.height).to eq player_params[:player][:height]
          expect(new_player.team).to eq river
          expect(response).to redirect_to admin_players_path
        end
      end
    end
  end

  describe 'GET #show' do
    let(:player) { FactoryGirl.create(:player) }

    context 'when admin_user is not logged in' do
      it 'should render show view page' do
        get :show, id: player.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render show view page' do
        get :show, id: player.id

        expect(response).to render_template :show
      end
    end
  end

  describe 'PATCH #update' do
    let(:player) { FactoryGirl.create(:player) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        patch :update, id: player.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should update old player with given params and redirect to show view page' do
        player_params = {
          id: player.id,
          player: {
            first_name: 'Daniel',
            last_name: 'Osvaldo',
            position: Position::FORWARD,
            description: 'bla bla',
            birthday: '1985-4-2',
            nationality: Country::ARGENTINA,
            weight: 85,
            height: 1.90,
            team_id: boca.id,
          }
        }

        expect { patch :update, player_params }.to change { Player.count }.by(0)

        updated_player = Player.last
        expect(updated_player.first_name).to eq player_params[:player][:first_name]
        expect(updated_player.last_name).to eq player_params[:player][:last_name]
        expect(updated_player.position).to eq player_params[:player][:position]
        expect(updated_player.description).to eq player_params[:player][:description]
        expect(updated_player.birthday).to eq Date.new(1985, 4, 2)
        expect(updated_player.nationality).to eq player_params[:player][:nationality]
        expect(updated_player.weight).to eq player_params[:player][:weight]
        expect(updated_player.height).to eq player_params[:player][:height]
        expect(updated_player.team).to eq boca
        expect(response).to redirect_to admin_players_path
      end
    end
  end

  describe 'GET #edit' do
    let(:player) { FactoryGirl.create(:player) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :edit, id: player.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should render edit view page' do
        get :edit, id: player.id

        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:player) { FactoryGirl.create(:player) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        delete :destroy, id: player.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before(:each) { sign_in admin_user }

      it 'should delete given course content and redirect to index path' do
        delete :destroy, id: player.id

        expect{ Player.find player.id }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(response).to redirect_to admin_players_path
      end
    end
  end
end

require 'spec_helper'

describe Admin::MatchesController do
  let(:admin_user) { FactoryGirl.create(:user, :admin) }
  let(:tournament) { FactoryGirl.create(:tournament) }
  let(:river) { FactoryGirl.create(:team) }
  let(:boca) { FactoryGirl.create(:team) }
  let(:slo) { FactoryGirl.create(:team) }
  let(:river_boca) { FactoryGirl.create(:match, local_team: river, visitor_team: boca, tournament: tournament) }
  let(:river_slo) { FactoryGirl.create(:match, local_team: river, visitor_team: slo, tournament: tournament) }
  let(:now) { DateTime.now.strftime('%Y-%m-%d %H:%M') }
  let(:yesterday) { DateTime.yesterday.strftime('%Y-%m-%d %H:%M') }

  describe 'GET #index' do
    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :index

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before { sign_in admin_user }

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
      before { sign_in admin_user }

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
      before { sign_in admin_user }
      let(:match_params) do
        {
          match: {
            title: 'RIV vs SLO',
            tournament_id: tournament.id,
            local_team_id: river.id,
            visitor_team_id: slo.id,
            datetime: now,
          }
        }
      end

      context 'when request succeeds' do
        it 'should create a new course content with given params and redirect to show view page' do
          expect { post :create, match_params }.to change { Match.count }.by(1)

          new_match = Match.last
          expect(new_match.title).to eq 'RIV vs SLO'
          expect(new_match.tournament).to eq tournament
          expect(new_match.local_team).to eq river
          expect(new_match.visitor_team).to eq slo
          expect(new_match.datetime).to eq DateTime.strptime(now, '%Y-%m-%d %H:%M')
          expect(response).to redirect_to admin_matches_path
        end
      end
    end
  end

  describe 'GET #show' do
    let(:match) { FactoryGirl.create(:match) }

    context 'when admin_user is not logged in' do
      it 'should render show view page' do
        get :show, id: match.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before { sign_in admin_user }

      it 'should render show view page' do
        get :show, id: match.id

        expect(response).to render_template :show
      end
    end
  end

  describe 'PATCH #update' do
    let(:match) { FactoryGirl.create(:match) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        patch :update, id: match.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before { sign_in admin_user }

      it 'should update old match with given params and redirect to show view page' do
        match_params = {
          id: match.id,
          match: {
            title: 'RIV vs BOC',
            tournament_id: tournament.id,
            local_team_id: river.id,
            visitor_team_id: boca.id,
            datetime: yesterday,
          }
        }

        expect { patch :update, match_params }.to change { Match.count }.by(0)

        updated_match = Match.last
        expect(updated_match.title).to eq 'RIV vs BOC'
        expect(updated_match.tournament).to eq tournament
        expect(updated_match.local_team).to eq river
        expect(updated_match.visitor_team).to eq boca
        expect(updated_match.datetime).to eq DateTime.strptime(yesterday, '%Y-%m-%d %H:%M')
        expect(response).to redirect_to admin_matches_path
      end
    end
  end

  describe 'GET #edit' do
    let(:match) { FactoryGirl.create(:match) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        get :edit, id: match.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before { sign_in admin_user }

      it 'should render edit view page' do
        get :edit, id: match.id

        expect(response).to render_template :edit
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:match) { FactoryGirl.create(:match) }

    context 'when admin_user is not logged in' do
      it 'should be redirect to root path' do
        delete :destroy, id: match.id

        expect(response).to redirect_to admin_login_path
      end
    end

    context 'when admin_user is logged in' do
      before { sign_in admin_user }

      it 'should delete given course content and redirect to index path' do
        delete :destroy, id: match.id

        expect{ Match.find match.id }.to raise_exception(ActiveRecord::RecordNotFound)
        expect(response).to redirect_to admin_matches_path
      end
    end
  end
end

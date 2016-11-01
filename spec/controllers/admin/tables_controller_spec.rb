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

  describe 'POST #close' do
    let(:croupier) { Croupier.for table }
    let(:tournament) { table.tournament }
    let(:table_rules) { FactoryGirl.create(:table_rules, scored_goals: 1) }
    let(:players_stats) { PlayerStats.for_table table }

    before { sign_in admin_user }

    describe 'for public tables' do
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, points_for_winners: [200, 100], coins_for_winners: [50, 20]) }

      context 'when one user plays for a player that scores 2 goals and other user plays for a player that scores 5' do
        let(:first_user) { FactoryGirl.create(:user, :without_coins) }
        let(:first_match) { table.matches.first }
        let(:player_of_the_first_user) { first_match.local_team.players.last }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: first_match, scored_goals: 2) }
        let(:first_user_play) { PlaysHistory.new.made_by(first_user).in_table(table).last }

        let(:second_user) { FactoryGirl.create(:user, :without_coins) }
        let(:last_match) { table.matches.last }
        let(:player_of_the_second_user) { last_match.visitor_team.players.first }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: last_match, scored_goals: 5) }
        let(:second_user_play) { PlaysHistory.new.made_by(second_user).in_table(table).last }

        before do
          croupier.play(user: first_user, players: [player_of_the_first_user])
          croupier.play(user: second_user, players: [player_of_the_second_user])
          create_empty_stats_for_all table.matches
        end

        it 'closes the table and updates the total points for each user' do
          post :close, id: table.id
          table.reload

          expect(table).to be_closed
          expect(table.winners).to have(2).item
          expect(table.winners.first.user).to eq second_user
          expect(table.winners.first.position).to eq 1
          expect(table.winners.second.user).to eq first_user
          expect(table.winners.second.position).to eq 2

          expect(first_user_play.points).to eq 2
          expect(first_user.reload.coins).to eq 20
          expect(first_user.ranking_on_tournament(tournament).points).to eq 100

          expect(second_user_play.points).to eq 5
          expect(second_user.reload.coins).to eq 50
          expect(second_user.ranking_on_tournament(tournament).points).to eq 200
        end

        it 'sends one email to each user with the results of their plays' do
          NotificationType.create!(name: 'result')

          post :close, id: table.id

          results_emails = ResultsMailer.deliveries
          expect(results_emails).to have(2).items

          points_of_the_player_of_the_first_user = PlayPointsCalculator.new.call_for_player(first_user_play, player_of_the_first_user)
          expect(results_emails.first.to).to include first_user.email
          expect(results_emails.first.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.first.body).to include "Los Resultados de #{table.title}"
          expect(results_emails.first.body).to include "Saliste #{table.position(first_user)}"
          expect(results_emails.first.body).to include "#{player_of_the_first_user.name}, sumo: #{points_of_the_player_of_the_first_user} PTS"
          expect(results_emails.first.body).to include "TOTAL: #{points_of_the_player_of_the_first_user} PTS"

          points_of_the_player_of_the_second_user = PlayPointsCalculator.new.call_for_player(second_user_play, player_of_the_second_user)
          expect(results_emails.second.to).to include second_user.email
          expect(results_emails.second.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.second.body).to include "Los Resultados de #{table.title}"
          expect(results_emails.second.body).to include "Saliste #{table.position(second_user)}"
          expect(results_emails.second.body).to include "#{player_of_the_second_user.name}, sumo: #{points_of_the_player_of_the_second_user} PTS"
          expect(results_emails.second.body).to include "TOTAL: #{points_of_the_player_of_the_second_user} PTS"
        end
      end
    end

    describe 'for private tables' do
      let(:group) { FactoryGirl.create(:group) }
      let(:table) { FactoryGirl.create(:table, number_of_players: 1, table_rules: table_rules, group: group, entry_coins_cost: 99, points_for_winners: []) }

      context 'when one user plays for a player that scores 2 goals and other user plays for a player that scores 5' do
        let(:first_user) { FactoryGirl.create(:user, :with_coins, coins: 99) }
        let(:first_match) { table.matches.first }
        let(:player_of_the_first_user) { first_match.local_team.players.last }
        let!(:first_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_first_user, match: first_match, scored_goals: 2) }
        let(:first_user_play) { PlaysHistory.new.made_by(first_user).in_table(table).last }

        let(:second_user) { FactoryGirl.create(:user, :with_coins, coins: 99) }
        let(:last_match) { table.matches.last }
        let(:player_of_the_second_user) { last_match.visitor_team.players.first }
        let!(:second_player_stats) { FactoryGirl.create(:player_stats, player: player_of_the_second_user, match: last_match, scored_goals: 5) }
        let(:second_user_play) { PlaysHistory.new.made_by(second_user).in_table(table).last }

        before do
          group.update_attributes!(users: [first_user, second_user])
          croupier.play(user: first_user, players: [player_of_the_first_user])
          croupier.play(user: second_user, players: [player_of_the_second_user])
          create_empty_stats_for_all table.matches
        end

        it 'closes the table and updates the total points for each user' do
          pot_prize = table.entry_coins_cost * 2

          post :close, id: table.id
          table.reload

          expect(table).to be_closed
          expect(table.points_for_winners).to be_empty
          expect(table.coins_for_winners).to eq [pot_prize]
          expect(table.winners).to have(2).item
          expect(table.winners.first.user).to eq second_user
          expect(table.winners.first.position).to eq 1
          expect(table.winners.second.user).to eq first_user
          expect(table.winners.second.position).to eq 2

          expect(first_user_play.points).to eq 2
          expect(first_user.reload.coins).to eq 0
          expect(first_user.ranking_on_tournament(tournament)).to be_nil

          expect(second_user_play.points).to eq 5
          expect(second_user.reload.coins).to eq(pot_prize)
          expect(second_user.ranking_on_tournament(tournament)).to be_nil
        end

        it 'sends one email to each user with the results of their plays' do
          NotificationType.create!(name: 'result')

          post :close, id: table.id

          results_emails = ResultsMailer.deliveries
          expect(results_emails).to have(2).items

          points_of_the_player_of_the_first_user = PlayPointsCalculator.new.call_for_player(first_user_play, player_of_the_first_user)
          expect(results_emails.first.to).to include first_user.email
          expect(results_emails.first.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.first.body).to include "Los Resultados de #{table.title}"
          expect(results_emails.first.body).to include "Saliste #{table.position(first_user)}"
          expect(results_emails.first.body).to include "#{player_of_the_first_user.name}, sumo: #{points_of_the_player_of_the_first_user} PTS"
          expect(results_emails.first.body).to include "TOTAL: #{points_of_the_player_of_the_first_user} PTS"

          points_of_the_player_of_the_second_user = PlayPointsCalculator.new.call_for_player(second_user_play, player_of_the_second_user)
          expect(results_emails.second.to).to include second_user.email
          expect(results_emails.second.from).to include ResultsMailer::INFO_MAIL
          expect(results_emails.second.body).to include "Los Resultados de #{table.title}"
          expect(results_emails.second.body).to include "Saliste #{table.position(second_user)}"
          expect(results_emails.second.body).to include "#{player_of_the_second_user.name}, sumo: #{points_of_the_player_of_the_second_user} PTS"
          expect(results_emails.second.body).to include "TOTAL: #{points_of_the_player_of_the_second_user} PTS"
        end
      end
    end
  end
end

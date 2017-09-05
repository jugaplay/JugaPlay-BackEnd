require 'spec_helper'

describe Api::V1::TablesController do
  let(:user) { FactoryGirl.create(:user) }
  
  describe 'GET #index' do
    let!(:public_table) { FactoryGirl.create(:table) }
    let!(:private_table_for_user) { FactoryGirl.create(:table, group: FactoryGirl.create(:group, users: [user])) }
    let!(:private_table_excluding_user) { FactoryGirl.create(:table, group: FactoryGirl.create(:group)) }

    context 'when the user is logged in' do
      before { sign_in user }

      it 'returns json of the public tables and the private tables that the user can play' do
        get :index

        expect(response.status).to eq 200
        expect(response_body).to have(2).items
        expected_data = [public_table, private_table_for_user].map do |table|
          {
            id: table.id,
            title: table.title,
            has_password: false,
            entry_cost_value: table.entry_cost.value,
            entry_cost_type: table.entry_cost.currency,
            multiplier_chips_cost: table.multiplier_chips_cost,
            number_of_players: table.number_of_players,
            pot_prize_type: table.pot_prize.currency,
            pot_prize_value: table.pot_prize.value,
            start_time: table.start_time.strftime('%d/%m/%Y - %H:%M'),
            end_time: table.end_time.strftime('%d/%m/%Y - %H:%M'),
            description: table.description,
            has_been_played_by_user: table.has_played?(user),
            played_by_user_type: 'N/A',
            multiplier: table.multiplier_for(user),
            tournament_id: table.tournament_id,
            private: table.private?,
            amount_of_users_playing: table.amount_of_users_playing,
            amount_of_users_challenge: table.challenge_plays.count,
            amount_of_users_league: table.league_plays.count,
            amount_of_users_training: table.training_plays.count,
            entry_coins_cost: (table.entry_cost.coins? ? table.entry_cost.value : 0),
            pot_prize: (table.pot_prize.coins? ? table.pot_prize.value : 0),
            bet_multiplier: table.multiplier_for(user)
          }
        end

        expected_data.second[:group] = { name: private_table_for_user.group.name, size: private_table_for_user.group.size }
        expect(response_body).to include expected_data.first
        expect(response_body).to include expected_data.second
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

  describe 'GET #show' do
    let!(:public_table) { FactoryGirl.create(:table, table_rules: TableRules.new) }
    let!(:private_table_for_user) { FactoryGirl.create(:table, group: FactoryGirl.create(:group, users: [user]), table_rules: TableRules.new) }
    let!(:private_table_excluding_user) { FactoryGirl.create(:table, group: FactoryGirl.create(:group)) }

    before do
      FactoryGirl.create(:table_ranking, table: public_table)
      FactoryGirl.create(:table_ranking, table: private_table_for_user)
      FactoryGirl.create(:table_ranking, table: private_table_excluding_user)
    end

    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user can play in the requested table' do
        context 'when the user requests a private table that is allowed to play' do
          it 'returns json of the table' do
            get :show, id: private_table_for_user.id

            expect(response.status).to eq 200
            expect(response_body[:id]).to eq private_table_for_user.id
            expect(response_body[:title]).to eq private_table_for_user.title
            expect(response_body[:has_password]).to be_falsey
            expect(response_body[:number_of_players]).to eq private_table_for_user.number_of_players
            expect(response_body[:entry_cost_value]).to eq private_table_for_user.entry_cost.value
            expect(response_body[:entry_cost_type]).to eq private_table_for_user.entry_cost.currency
            expect(response_body[:multiplier_chips_cost]).to eq private_table_for_user.multiplier_chips_cost
            expect(response_body[:tournament_id]).to eq private_table_for_user.tournament_id
            expect(response_body[:start_time]).to eq private_table_for_user.start_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:end_time]).to eq private_table_for_user.end_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:description]).to eq private_table_for_user.description
            expect(response_body[:private]).to eq private_table_for_user.private?
            expect(response_body[:amount_of_users_playing]).to eq private_table_for_user.amount_of_users_playing
            expect(response_body[:amount_of_users_challenge]).to eq private_table_for_user.challenge_plays.count
            expect(response_body[:amount_of_users_league]).to eq private_table_for_user.league_plays.count
            expect(response_body[:amount_of_users_training]).to eq private_table_for_user.training_plays.count
            expect(response_body[:prizes]).to have(private_table_for_user.prizes.size).items
            expect(response_body[:winners]).to have(1).item
            expect(response_body[:matches]).to have(private_table_for_user.matches.size).items
            expect(response_body[:group]).not_to be_nil
            expect(response_body[:table_rules]).not_to be_nil
          end
        end

        context 'when the user requests a public table' do
          it 'returns json of the table' do
            get :show, id: public_table.id

            expect(response.status).to eq 200
            expect(response_body[:id]).to eq public_table.id
            expect(response_body[:title]).to eq public_table.title
            expect(response_body[:has_password]).to be_falsey
            expect(response_body[:number_of_players]).to eq public_table.number_of_players
            expect(response_body[:entry_cost_value]).to eq public_table.entry_cost.value
            expect(response_body[:entry_cost_type]).to eq public_table.entry_cost.currency
            expect(response_body[:multiplier_chips_cost]).to eq public_table.multiplier_chips_cost
            expect(response_body[:tournament_id]).to eq public_table.tournament_id
            expect(response_body[:start_time]).to eq public_table.start_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:end_time]).to eq public_table.end_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:description]).to eq public_table.description
            expect(response_body[:private]).to eq public_table.private?
            expect(response_body[:amount_of_users_playing]).to eq public_table.amount_of_users_playing
            expect(response_body[:amount_of_users_challenge]).to eq public_table.challenge_plays.count
            expect(response_body[:amount_of_users_league]).to eq public_table.league_plays.count
            expect(response_body[:amount_of_users_training]).to eq public_table.training_plays.count
            expect(response_body[:prizes]).to have(public_table.prizes.size).items
            expect(response_body[:winners]).to have(1).item
            expect(response_body[:matches]).to have(public_table.matches.size).items
            expect(response_body[:group]).to be_nil
            expect(response_body[:table_rules]).not_to be_nil
          end
        end
      end

      context 'when the user is not allowed to play in the requested table' do
        it 'responses with a json error' do
          get :show, id: private_table_excluding_user.id

          expect(response.status).to eq 400
          expect(response_body[:errors]).to include Api::V1::TablesController::PRIVATE_TABLE_NOT_ALLOWED
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :show, id: public_table.id

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #create' do
    let(:group) { FactoryGirl.create(:group) }
    let(:match) { FactoryGirl.create(:match) }
    let(:table_params) do
      {
        table: {
          title: 'Table title',
          description: 'bla bla bla',
          group_id: group.id,
          match_id: match.id,
          entry_cost_value: 100,
          entry_cost_type: Money::CHIPS
        }
      }
    end

    context 'when the user is logged in' do
      before { sign_in user }

      context 'when request succeeds' do
        it 'creates a new private table for the given group' do
          expect { post :create, table_params }.to change { Table.count }.by(1)

          expect(response.status).to eq 200
          expect(response).to render_template :show

          table = Table.last
          expect(table).to be_opened
          expect(table).to be_private
          expect(table.group).to eq group
          expect(table.title).to eq table_params[:table][:title]
          expect(table.description).to eq table_params[:table][:description]
          expect(table.number_of_players).to eq 3
          expect(table.entry_cost).to eq 100.chips
          expect(table.multiplier_chips_cost).to eq 0
          expect(table.points_for_winners).to be_empty
          expect(table.prizes).to be_empty
          expect(table.matches).to match_array [match]
          expect(table.start_time).to eq match.datetime
          expect(table.end_time).to eq (match.datetime + 2.hours)
        end

        it 'creates challenge notifications for all the group members' do
          expect { post :create, table_params }.to change { Notification.count }.by 2

          table = Table.last
          Notification.all.each do |notification|
            expect(notification.title).to eq group.name
            expect(notification.text).to eq table.title
            expect(group.users).to include notification.user
          end
        end

        context 'when no entry cost value was given' do
          it 'creates a table with 0 chips entry cost for the given group' do
            params = table_params
            params[:table].delete(:entry_cost_value)

            expect { post :create, params }.to change { Table.count }.by(1)

            expect(response.status).to eq 200
            expect(response).to render_template :show

            table = Table.last
            expect(table).to be_opened
            expect(table).to be_private
            expect(table.group).to eq group
            expect(table.entry_cost).to eq 0.chips
          end
        end

        context 'when no entry cost was given' do
          it 'creates a table with 0 coins cost for the given group' do
            params = table_params
            params[:table].delete(:entry_cost_value)
            params[:table].delete(:entry_cost_type)

            expect { post :create, params }.to change { Table.count }.by(1)

            expect(response.status).to eq 200
            expect(response).to render_template :show

            table = Table.last
            expect(table).to be_opened
            expect(table).to be_private
            expect(table.group).to eq group
            expect(table.entry_cost).to eq 0.coins
          end
        end
      end

      context 'when request fails' do
        context 'when a required parameter is missing' do
          let(:mandatory_fields) { [:title, :description] }

          it 'does not create a table and renders an error' do
            mandatory_fields.each do |param|
              missing_params = table_params.deep_dup
              missing_params[:table].delete(param)

              expect { post :create, missing_params }.to_not change { Table.count }

              expect(Notification.count).to eq 0
              expect(response.status).to eq 200
              expect(response_body[:errors][param]).to include "can't be blank"
            end
          end
        end

        context 'when no group is given' do
          it 'does not create a table and renders an error' do
            params = table_params
            params[:table].delete(:group_id)

            expect { post :create, params }.not_to change { Table.count }

            expect(Notification.count).to eq 0
            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::TablesController::GROUP_MUST_BE_GIVEN
          end
        end

        context 'when the entry coins cost is negative' do
          it 'does not create a table and renders an error' do
            params = table_params
            params[:table][:entry_cost_value] = -1

            expect { post :create, params }.not_to change { Table.count }

            expect(Notification.count).to eq 0
            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::TablesController::ENTRY_COST_VALUE_MUST_BE_GREATER_THAN_OR_EQ_TO_ZERO
          end
        end

        context 'when the match id does not exist' do
          it 'does not create a table and renders an error' do
            params = table_params
            params[:table][:match_id] = 1000

            expect { post :create, params }.not_to change { Table.count }

            expect(Notification.count).to eq 0
            expect(response.status).to eq 422
            expect(response_body[:errors]).to include Api::V1::TablesController::MATCH_NOT_FOUND
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        expect { post :create, table_params }.not_to change { Table.count }

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #multiply' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the given table exists' do
        let(:table) { FactoryGirl.create(:table, multiplier_chips_cost: 1) }
        let!(:play) { FactoryGirl.create(:play, table: table, user: user) }

        before { user.win_money! 100.chips }

        context 'when a multiplier is given' do
          let(:params) do
            { id: table.id, multiplier: multiplier }
          end

          context 'when the given multiplier was 3' do
            let(:multiplier) { 3 }

            it 'sets the play multiplier and returns a json with the play data' do
              post :multiply_play, params

              expect(response).to render_template(partial: 'api/v1/plays/_play')

              expect(play.reload.multiplier).to eq 3
            end
          end

          context 'when the given multiplier was invalid' do
            let(:multiplier) { -1 }

            it 'returns a json error' do
              post :multiply_play, params

              expect(response.status).to eq 400
              expect(response_body[:errors].first).to include Api::V1::TablesController::MULTIPLIER_MUST_BE_GREATER_THAN_ONE
            end
          end
        end

        context 'when no multiplier was given' do
          let(:params) do
            { id: table.id, multiplier: '' }
          end

          it 'returns a json error' do
            post :multiply_play, params

            expect(response.status).to eq 400
            expect(response_body[:errors].first).to include Api::V1::TablesController::MULTIPLIER_MUST_BE_GREATER_THAN_ONE
          end
        end
      end

      context 'when the given table does not exist' do
        let(:params) do
          { id: 1, multiplier: 2 }
        end

        it 'returns a json error' do
          post :multiply_play, params

          expect(response.status).to eq 422
          expect(response_body[:errors]).to include 'No se encontró la mesa solicitada'
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :multiply_play, id: 1, multiplier: 1

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

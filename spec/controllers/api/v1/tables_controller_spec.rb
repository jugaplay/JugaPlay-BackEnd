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
            entry_coins_cost: table.entry_coins_cost,
            number_of_players: table.number_of_players,
            pot_prize: table.expending_coins,
            start_time: table.start_time.strftime('%d/%m/%Y - %H:%M'),
            end_time: table.end_time.strftime('%d/%m/%Y - %H:%M'),
            description: table.description,
            has_been_played_by_user: !table.did_not_play?(user),
            tournament_id: table.tournament_id,
            private: table.private?,
            amount_of_users_playing: table.amount_of_users_playing
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
            expect(response_body[:entry_coins_cost]).to eq private_table_for_user.entry_coins_cost
            expect(response_body[:tournament_id]).to eq private_table_for_user.tournament_id
            expect(response_body[:start_time]).to eq private_table_for_user.start_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:end_time]).to eq private_table_for_user.end_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:description]).to eq private_table_for_user.description
            expect(response_body[:private]).to eq private_table_for_user.private?
            expect(response_body[:amount_of_users_playing]).to eq private_table_for_user.amount_of_users_playing
            expect(response_body[:coins_for_winners]).to have(private_table_for_user.coins_for_winners.size).items
            expect(response_body[:winners]).to be_empty
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
            expect(response_body[:entry_coins_cost]).to eq public_table.entry_coins_cost
            expect(response_body[:tournament_id]).to eq public_table.tournament_id
            expect(response_body[:start_time]).to eq public_table.start_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:end_time]).to eq public_table.end_time.strftime('%d/%m/%Y - %H:%M')
            expect(response_body[:description]).to eq public_table.description
            expect(response_body[:private]).to eq public_table.private?
            expect(response_body[:amount_of_users_playing]).to eq public_table.amount_of_users_playing
            expect(response_body[:coins_for_winners]).to have(public_table.coins_for_winners.size).items
            expect(response_body[:winners]).to be_empty
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
          entry_coins_cost: 100
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
          expect(table.entry_coins_cost).to eq table_params[:table][:entry_coins_cost]
          expect(table.points_for_winners).to be_empty
          expect(table.coins_for_winners).to be_empty
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

        context 'when no entry coins cost was given' do
          it 'creates a table with no entry coins cost for the given group' do
            params = table_params
            params[:table].delete(:entry_coins_cost)

            expect { post :create, params }.to change { Table.count }.by(1)

            expect(response.status).to eq 200
            expect(response).to render_template :show

            table = Table.last
            expect(table).to be_opened
            expect(table).to be_private
            expect(table.group).to eq group
            expect(table.entry_coins_cost).to eq 0
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
            params[:table][:entry_coins_cost] = -1

            expect { post :create, params }.not_to change { Table.count }

            expect(Notification.count).to eq 0
            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::TablesController::ENTRY_COINS_COST_MUST_BE_GREATER_THAN_OR_EQ_TO_ZERO
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
end

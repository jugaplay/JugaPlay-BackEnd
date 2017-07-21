require 'spec_helper'

describe Api::V1::CroupierController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'POST #play' do
    let(:play_params) do
      {
        table_id: table_id,
        player_ids: player_ids
      }
    end

    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the request succeeds' do
        let(:table) { FactoryGirl.create(:table, number_of_players: 2) }
        let(:table_id) { table.id }
        let(:first_player) { table.players.last }
        let(:second_player) { table.players.first }
        let(:player_ids) { [first_player.id, second_player.id] }

        context 'when the user does not bet for the table' do
          it 'creates a play for the given user, table and players and renders a json of it' do
            expect { post :play, play_params }.to change { Play.count }.by(1)

            play = Play.last
            expect(play.user).to eq user
            expect(play.player_selections).to have(2).items
            expect(play.player_selections.first.player).to eq first_player
            expect(play.player_selections.second.player).to eq second_player
            expect(play.table).to eq table
            expect(play.cost).to eq 0.coins

            expect(response).to render_template(partial: 'api/v1/plays/_play')
            expect(response.status).to eq 200
            expect(response_body[:id]).to eq play.id
            expect(response_body[:cost_value]).to eq play.cost.value
            expect(response_body[:cost_type]).to eq play.cost.currency
            expect(response_body[:table][:title]).to eq table.title
            expect(response_body[:players]).to have(player_ids.count).items
          end
        end

        context 'when the user bets for the table' do
          let(:bet_play_params) { play_params.merge(bet: true) }

          before { table.update_attributes!(entry_cost: entry_cost) }

          context 'when the user can pay the table entry coins cost' do
            let(:entry_cost) { user.coins }

            it 'creates a play for the given user, table and players and renders a json of it' do
              expect { post :play, bet_play_params }.to change { Play.count }.by(1)

              play = Play.last
              expect(play.user).to eq user
              expect(play.player_selections).to have(2).items
              expect(play.player_selections.first.player).to eq first_player
              expect(play.player_selections.second.player).to eq second_player
              expect(play.table).to eq table
              expect(play.cost).to eq table.entry_cost

              expect(response).to render_template(partial: 'api/v1/plays/_play')
              expect(response.status).to eq 200
              expect(response_body[:id]).to eq play.id
              expect(response_body[:cost_value]).to eq play.cost.value
              expect(response_body[:cost_type]).to eq play.cost.currency
              expect(response_body[:table][:title]).to eq table.title
              expect(response_body[:players]).to have(player_ids.count).items
            end
          end

          context 'when the user can not pay the table entry coins cost' do
            let(:entry_cost) { user.coins + 10.coins }

            it 'does not create a play and renders an error' do
              expect { post :play, bet_play_params }.not_to change { Play.count }

              expect(response.status).to eq 200
              expect(response_body[:errors]).to eq 'User does not have enough coins to bet'
            end
          end
        end
      end

      context 'when the request fails' do
        context 'when a non-existing table id is given' do
          let(:table_id) { 1 }
          let(:player_ids) { [FactoryGirl.create(:player).id] }

          it 'does not create a play and renders an error' do
            expect { post :play, play_params }.not_to change { Play.count }

            expect(response.status).to eq 422
            expect(response_body[:errors]).to include Api::V1::CroupierController::TABLE_NOT_FOUND
          end
        end

        context 'when a player id that does not belong to the table is given' do
          let(:table_id) { FactoryGirl.create(:table, number_of_players: 1).id }
          let(:player_ids) { [FactoryGirl.create(:player).id] }

          it 'does not create a play and renders an error' do
            expect { post :play, play_params }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq 'Cannot choose this player for this table'
          end
        end

        context 'when the user has already played in the given table' do
          let!(:existing_play) { FactoryGirl.create(:play, user: user) }
          let(:table_id) { existing_play.table.id }
          let(:player_ids) { existing_play.players.map(&:id) }

          it 'does not create a play and renders an error' do
            expect { post :play, play_params }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq 'Given user has already played in this table'
          end
        end

        context 'when the number of given players is wrong' do
          let(:table_id) { FactoryGirl.create(:table, number_of_players: 2).id }
          let(:player_ids) { [] }

          it 'does not create a play and renders an error' do
            expect { post :play, play_params }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq 'The amount of given players is not allowed in this table'
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'creates a play for the given user, table and players' do
        expect { post :play, table_id: 1, player_ids: [1] }.not_to change { Play.count }

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

require 'spec_helper'

describe Api::V1::CroupierController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'POST #play' do
    let(:table) { FactoryGirl.create(:table) }
    let(:players) { Player.all.sample(table.number_of_players) }

    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the request succeeds' do
        context 'when the user does not bet for the table' do
          it 'creates a play for the given user, table and players and renders a json of it' do
            expect { post :play, table_id: table.id, player_ids: players.map(&:id) }.to change { Play.count }.by(1)

            play = Play.last
            expect(play.user).to eq user
            expect(play.players).to match_array players
            expect(play.table).to eq table
            expect(play.bet_coins).to eq 0

            expect(response).to render_template(partial: 'api/v1/plays/_play')
            expect(response.status).to eq 200
            expect(response_body[:id]).to eq play.id
            expect(response_body[:bet_coins]).to eq play.bet_coins
            expect(response_body[:table][:title]).to eq table.title
            expect(response_body[:players]).to have(players.count).items
          end
        end

        context 'when the user bets for the table' do
          before { table.update_attributes(entry_coins_cost: entry_coins_cost) }

          context 'when the user can pay the table entry coins cost' do
            let(:entry_coins_cost) { user.coins }

            it 'creates a play for the given user, table and players and renders a json of it' do
              expect { post :play, table_id: table.id, bet: true, player_ids: players.map(&:id) }.to change { Play.count }.by(1)

              play = Play.last
              expect(play.user).to eq user
              expect(play.players).to match_array players
              expect(play.table).to eq table
              expect(play.bet_coins).to eq table.entry_coins_cost

              expect(response).to render_template(partial: 'api/v1/plays/_play')
              expect(response.status).to eq 200
              expect(response_body[:id]).to eq play.id
              expect(response_body[:bet_coins]).to eq play.bet_coins
              expect(response_body[:table][:title]).to eq table.title
              expect(response_body[:players]).to have(players.count).items
            end
          end

          context 'when the user can not pay the table entry coins cost' do
            let(:entry_coins_cost) { user.coins + 10 }

            it 'does not create a play and renders an error' do
              expect { post :play, table_id: table.id, bet: true, player_ids: players.map(&:id) }.not_to change { Play.count }

              expect(response.status).to eq 200
              expect(response_body[:errors]).to eq 'User does not have enough coins to bet'
            end
          end
        end
      end

      context 'when the request fails' do
        context 'when a non-existing table id is given' do
          it 'does not create a play and renders an error' do
            expect { post :play, table_id: table.id + 5, player_ids: players.map(&:id) }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq "Couldn't find Table with 'id'=#{table.id + 5}"
          end
        end

        context 'when a non-existing player id is given' do
          it 'does not create a play and renders an error' do
            player_ids = players.map(&:id)
            player_ids[player_ids.count - 1] = FactoryGirl.create(:player).id

            expect { post :play, table_id: table.id, player_ids: player_ids }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq 'Cannot choose this player for this table'
          end
        end

        context 'when the user has already played in the given table' do
          let!(:existing_play) { FactoryGirl.create(:play, user: user, table: table) }

          it 'does not create a play and renders an error' do
            expect { post :play, table_id: table.id, player_ids: players.map(&:id) }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq 'Given user has already played in this table'
          end
        end

        context 'when the number of given players is wrong' do
          it 'does not create a play and renders an error' do
            expect { post :play, table_id: table.id, player_ids: [] }.not_to change { Play.count }

            expect(response.status).to eq 200
            expect(response_body[:errors]).to eq 'The amount of given players is not allowed in this table'
          end
        end
      end
    end

    context 'when the user is not logged in' do
      it 'creates a play for the given user, table and players' do
        expect { post :play, table_id: table.id, player_ids: players.map(&:id) }.not_to change { Play.count }

        expect(response.status).to eq 401
        expect(response_body[:error]).to eq 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

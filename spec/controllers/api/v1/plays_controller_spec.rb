require 'spec_helper'

describe Api::V1::PlaysController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET #index' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has not made any plays' do
        it 'returns an empty json' do
          get :index

          expect(response.status).to eq 200
          expect(response_body).to eq []
        end
      end

      context 'when the user has made some plays' do
        let(:table) { FactoryGirl.create(:table, :with_table_rules) }
        let!(:play) { FactoryGirl.create(:play, user: user, table: table) }
        let(:another_table) { FactoryGirl.create(:table, :private, :with_table_rules) }
        let!(:another_play) { FactoryGirl.create(:play, user: user, table: another_table) }

        before { another_table.group.add(user) }

        context 'when the table is still open' do
          it 'returns json of an empty list' do
            get :index

            expect(response.status).to eq 200
            expect(response_body).to be_empty
          end
        end

        context 'when the tables are closed' do
          before do
            table.close!
            another_table.close!

            create_empty_stats_for_all table.matches
            create_empty_stats_for_all another_table.matches
          end

          it 'returns json of them' do
            get :index

            expect(response.status).to eq 200
            expect(response_body).to have(2).items

            user.plays.each do |play|
              play_data = {
                  id: play.id,
                  start_time: play.table.start_time,
                  bet_base_coins: 0,
                  bet_multiplier: nil,
                  points: 'N/A',
                  earn_coins: 'N/A',
                  players: play.players.map { |player| {
                      id: player.id,
                      first_name: player.first_name,
                      last_name: player.last_name,
                      team: player.team.name,
                      team_id: player.team.id,
                      points: PlayerPointsCalculator.new.call(table, player)
                  }},
                  table: {
                      id: play.table.id,
                      title: play.table.title,
                      position: 'N/A',
                      payed_points: 'N/A'
                  }
              }
              play_data[:table][:group_name] = play.table.group.name if play.private?
              expect(response_body).to include play_data
            end
          end
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

  describe 'GET #show' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the play exists' do
        let(:play) { FactoryGirl.create(:play) }

        context 'when the play belongs to the logged user' do
          before { play.update_attributes!(user: user) }

          it 'returns a json with the play data' do
            get :show, id: play.id

            expect(response.status).to eq 200
            expect(response_body[:id]).to eq play.id
            expect(response_body[:bet_base_coins]).to eq play.bet_base_coins
            expect(response_body[:bet_multiplier]).to be_nil
            expect(response_body[:points]).to eq 'N/A'
            expect(response_body[:earn_coins]).to eq 'N/A'
          end
        end

        context 'when the play does not belong to the logged user' do

          it 'returns a json error' do
            get :show, id: play.id

            expect(response.status).to eq 422
            expect(response_body[:errors]).to include 'No se encontró la jugada solicitada'
          end
        end
      end

      context 'when the play does not exist' do
        it 'returns a json error' do
          get :show, id: 1

          expect(response.status).to eq 422
          expect(response_body[:errors]).to include 'No se encontró la jugada solicitada'
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :show, id: 1

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #multiply' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the play exists' do
        let(:play) { FactoryGirl.create(:play) }

        context 'when the play belongs to the logged user' do
          before { play.update_attributes!(user: user) }

          context 'when a multiplier is given' do
            let(:params) do
              { id: play.id, multiplier: multiplier }
            end

            context 'when the given multiplier was 3' do
              let(:multiplier) { 3 }

              it 'sets the play multiplier and returns a json with the play data' do
                post :multiply, params

                expect(response.status).to eq 200
                expect(response).to render_template :show

                expect(play.reload.bet_multiplier).to eq 3
                expect(play.reload.coins_bet_multiplier).to eq 3
              end
            end

            context 'when the given multiplier was invalid' do
              let(:multiplier) { -1 }

              it 'returns a json error' do
                post :multiply, params

                expect(response.status).to eq 400
                expect(response_body[:errors].first).to include 'Bet multiplier must be greater than or equal to 2'
              end
            end
          end

          context 'when no multiplier was given' do
            let(:params) do
              { id: play.id, multiplier: '' }
            end

            it 'returns a json error' do
              post :multiply, params

              expect(response.status).to eq 400
              expect(response_body[:errors].first).to include 'Bet multiplier must be greater than or equal to 2'
            end
          end
        end

        context 'when the play does not belong to the logged user' do
          let(:params) do
            { id: play.id, multiplier: 2 }
          end

          it 'returns a json error' do
            post :multiply, params

            expect(response.status).to eq 422
            expect(response_body[:errors]).to include 'No se encontró la jugada solicitada'
          end
        end
      end

      context 'when the play does not exist' do
        let(:params) do
          { id: 1, multiplier: 2 }
        end

        it 'returns a json error' do
          post :multiply, params

          expect(response.status).to eq 422
          expect(response_body[:errors]).to include 'No se encontró la jugada solicitada'
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :multiply, id: 1, multiplier: 1

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end
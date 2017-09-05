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
                cost_value: 0.0,
                cost_type: 'coins',
                points: 'N/A',
                prize_type: 'N/A',
                prize_value: 'N/A',
                leagues: [],
                type: play.type.to_s,
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
            expect(response_body[:cost_value]).to eq play.cost.value
            expect(response_body[:cost_type]).to eq play.cost.currency
            expect(response_body[:multiplier]).to be_nil
            expect(response_body[:points]).to eq 'N/A'
            expect(response_body[:prize_type]).to eq 'N/A'
            expect(response_body[:prize_value]).to eq 'N/A'
            expect(response_body[:type]).to eq 'league'
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
end

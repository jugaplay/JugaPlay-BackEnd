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
                bet_coins: 0,
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
end
require 'spec_helper'

describe Api::V1::PlaysController do
  let(:user) { FactoryGirl.create(:user) }
  
  describe 'GET #index' do
    context 'when the user is logged in' do
      before(:each) { sign_in user }

      context 'when the user has not made any plays' do
        it 'returns an empty json' do
          get :index
    
          expect(response.status).to eq 200
          expect(response_body).to eq []
        end
      end
      
      context 'when the user has made some plays' do
        let!(:play) { FactoryGirl.create(:play, user: user) }
        let!(:another_play) { FactoryGirl.create(:play, user: user) }
        
        it 'returns json of them' do
          get :index
    
          expect(response.status).to eq 200
          expect(response_body).to have(2).items

          user.plays.each do |play|
            play_data = {
              id: play.id,
              bet_coins: 0,
              points: 'N/A',
              players: play.players.map { |player| {
                id: player.id,
                first_name: player.first_name,
                last_name: player.last_name,
                team: player.team.name,
              }},
              table: {
                id: play.table.id,
                title: play.table.title,
                position: 'N/A',
                payed_points: 'N/A'
              }
            }
            expect(response_body).to include play_data
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
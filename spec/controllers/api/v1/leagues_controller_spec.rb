require 'spec_helper'

describe Api::V1::LeaguesController do
  let(:user) { FactoryGirl.create(:user) }
  
  describe 'GET #index' do
    let!(:league) { FactoryGirl.create(:league) }
    let!(:another_league) { FactoryGirl.create(:league) }

    context 'when the user is logged in' do
      before { sign_in user }

      it 'returns json of the public tables and the private tables that the user can play' do
        get :index

        expect(response.status).to eq 200
        expect(response_body).to have(2).items
        expected_data = [another_league, league].map do |league|
          {
            id: league.id,
            starts: league.starts_at.strftime('%d/%m/%Y - %H:%M'),
            ends: league.ends_at.strftime('%d/%m/%Y - %H:%M'),
            frequency: league.frequency_in_days,
            amount_of_matches: 2,
            users_playing: league.amount_of_rankings,
            status: league.status_cd,
            prizes: league.prizes_with_positions.map { |prize_with_position|
              {
                position: prize_with_position.first,
                prize_type: prize_with_position.second.currency,
                prize_value: prize_with_position.second.value
              }
            },
            user_league: {
              user_position: league.ranking_for_user(user).try(:position) || 'N/A',
              points_acumulative: league.ranking_for_user(user).try(:total_points) || 'N/A'
            }
          }
        end

        expect(response_body[:leagues]).to include expected_data.first
        expect(response_body[:leagues]).to include expected_data.second
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
    let!(:league) { FactoryGirl.create(:league) }

    context 'when the user is logged in' do
      before { sign_in user }

      it 'returns json of the table' do
        get :show, id: league.id

        expect(response.status).to eq 200
        expect(response_body[:league_data][:id]).to eq league.id
      end
    end
  end

  describe 'GET #actual' do
    let!(:league) { FactoryGirl.create(:league, status: :playing) }

    context 'when the user is logged in' do
      before { sign_in user }

      it 'returns json of the table' do
        get :actual, id: league.id

        expect(response.status).to eq 200
        expect(response_body[:league_data][:id]).to eq league.id
      end
    end
  end
end

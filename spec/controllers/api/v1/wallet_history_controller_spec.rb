require 'spec_helper'

describe Api::V1::WalletHistoryController do
  let(:user) { FactoryGirl.create(:user) }
  
  describe 'GET #index' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has not made any play' do
        it 'returns an empty json' do
          get :index
    
          expect(response.status).to eq 200

          expect(response_body[:total_prizes]).to eq 0
          expect(response_body[:last_month_prizes]).to eq 0
          expect(response_body[:detail_prizes]).to be_empty
        end
      end
      
      context 'when the user has made some plays' do
        let(:play) { FactoryGirl.create(:play, user: user) }
        let(:another_play) { FactoryGirl.create(:play, user: user) }
        let!(:table_raking) { FactoryGirl.create(:table_ranking, play: play, earned_coins: 40, points: 10, created_at: Time.now - 40.days) }
        let!(:another_table_raking) { FactoryGirl.create(:table_ranking, play: another_play, earned_coins: 50, points: 10, created_at: Time.now ) }

        it 'returns json of an empty list' do
          get :index

          expect(response.status).to eq 200

          expect(response_body[:total_prizes]).to eq 90
          expect(response_body[:last_month_prizes]).to eq 50
          expect(response_body[:detail_prizes]).to have(2).items
          expect(response_body[:detail_prizes].first[:coins]).to eq 50
          expect(response_body[:detail_prizes].second[:coins]).to eq 40
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
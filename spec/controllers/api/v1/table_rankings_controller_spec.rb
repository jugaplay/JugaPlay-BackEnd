require 'spec_helper'

describe Api::V1::TableRankingsController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET #index' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has some table rankings' do
        let!(:table_ranking) { FactoryGirl.create(:table_ranking, user: user) }
        let!(:another_table_ranking) { FactoryGirl.create(:table_ranking, user: user) }
        let!(:table_rankings_of_another_user) { FactoryGirl.create(:table_ranking) }

        it 'responds a json with the information of the table rankings of the user' do
          get :index

          expect(response_body[:table_rankings]).to have(2).items
          expect(response_body[:table_rankings].first[:id]).to eq table_ranking.id
          expect(response_body[:table_rankings].first[:coins]).to eq table_ranking.earned_coins
          expect(response_body[:table_rankings].first[:table_id]).to eq table_ranking.table.id
          expect(response_body[:table_rankings].first[:detail]).to eq table_ranking.detail
          expect(response_body[:table_rankings].second[:id]).to eq another_table_ranking.id
          expect(response_body[:table_rankings].second[:coins]).to eq another_table_ranking.earned_coins
          expect(response_body[:table_rankings].second[:table_id]).to eq another_table_ranking.table.id
          expect(response_body[:table_rankings].second[:detail]).to eq another_table_ranking.detail

          expect(response.status).to eq 200
          expect(response).to render_template :index
        end
      end

      context 'when the user does not have any table_ranking' do
        it 'responds a json with an empty body' do
          get :index

          expect(response_body[:table_rankings]).to be_empty
          expect(response.status).to eq 200
          expect(response).to render_template :index
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
require 'spec_helper'

describe Api::V1::PrizesController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET #index' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has some prizes' do
        let!(:prize) { FactoryGirl.create(:prize, user: user) }
        let!(:another_prize) { FactoryGirl.create(:prize, user: user) }
        let!(:prize_of_another_user) { FactoryGirl.create(:prize) }

        it 'responds a json with the information of the prizes of the user' do
          get :index

          expect(response_body[:prizes]).to have(2).items
          expect(response_body[:prizes].first[:id]).to eq prize.id
          expect(response_body[:prizes].first[:coins]).to eq prize.coins
          expect(response_body[:prizes].first[:table_id]).to eq prize.table.id
          expect(response_body[:prizes].first[:detail]).to eq prize.detail
          expect(response_body[:prizes].second[:id]).to eq another_prize.id
          expect(response_body[:prizes].second[:coins]).to eq another_prize.coins
          expect(response_body[:prizes].second[:table_id]).to eq another_prize.table.id
          expect(response_body[:prizes].second[:detail]).to eq another_prize.detail

          expect(response.status).to eq 200
          expect(response).to render_template :index
        end
      end

      context 'when the user does not have any prize' do
        it 'responds a json with an empty body' do
          get :index

          expect(response_body[:prizes]).to be_empty
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

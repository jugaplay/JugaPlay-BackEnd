require 'spec_helper'

describe Api::V1::NotificationsController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET #index' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has some notifications' do
        let!(:notification) { FactoryGirl.create(:notification, user: user) }
        let!(:another_notification) { FactoryGirl.create(:notification, user: user) }

        it 'responds a json with the information of the notifications of the user' do
          get :index

          expect(response_body[:notifications]).to have(2).items
          expect(response_body[:notifications].first[:id]).to eq another_notification.id
          expect(response_body[:notifications].first[:type]).to eq another_notification.type
          expect(response_body[:notifications].first[:title]).to eq another_notification.title
          expect(response_body[:notifications].first[:image]).to eq another_notification.image
          expect(response_body[:notifications].first[:text]).to eq another_notification.text
          expect(response_body[:notifications].first[:action]).to eq another_notification.action
          expect(response_body[:notifications].first[:read]).to eq another_notification.read
          expect(response_body[:notifications].second[:id]).to eq notification.id
          expect(response_body[:notifications].second[:type]).to eq notification.type
          expect(response_body[:notifications].second[:title]).to eq notification.title
          expect(response_body[:notifications].second[:image]).to eq notification.image
          expect(response_body[:notifications].second[:text]).to eq notification.text
          expect(response_body[:notifications].second[:action]).to eq notification.action
          expect(response_body[:notifications].second[:read]).to eq notification.read
          expect(response.status).to eq 200
          expect(response).to render_template :index
        end
      end

      context 'when the user does not have any notification' do
        it 'responds a json without notifications' do
          get :index

          expect(response_body[:notifications]).to be_empty
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

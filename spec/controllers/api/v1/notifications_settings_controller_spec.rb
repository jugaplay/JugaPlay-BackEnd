require 'spec_helper'

describe Api::V1::NotificationsSettingsController do
  let(:user) { FactoryGirl.create(:user) }
  let!(:notifications_setting) { FactoryGirl.create(:notifications_setting, user: user) }
  let!(:another_notifications_setting) { FactoryGirl.create(:notifications_setting) }

  describe 'GET #show' do
    context 'when the user is logged in' do
      before { sign_in user }

      it 'responds a json with the information of notifications setting of the the user' do
        get :show

        expect(response_body[:notifications_setting][:sms]).to eq notifications_setting.sms
        expect(response_body[:notifications_setting][:mail]).to eq notifications_setting.mail
        expect(response_body[:notifications_setting][:push]).to eq notifications_setting.push
        expect(response_body[:notifications_setting][:whatsapp]).to eq notifications_setting.whatsapp
        expect(response_body[:notifications_setting][:facebook]).to eq notifications_setting.facebook

        expect(response.status).to eq 200
        expect(response).to render_template :show
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        get :show

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'PUT/PATCH #update' do
    let(:notifications_setting_params) do
      {
        id: notifications_setting.id,
        notifications_setting: {
          sms: true,
          mail: true,
          push: true,
          whatsapp: true,
          facebook: true
        }
      }
    end

    context 'when the user is logged in' do
      before { sign_in user }

      context 'when request succeeds' do
        it 'updates the notifications setting and renders a json of it' do
          patch :update, notifications_setting_params

          updated_notifications_setting = notifications_setting.reload
          expect(updated_notifications_setting.sms).to be_truthy
          expect(updated_notifications_setting.push).to be_truthy
          expect(updated_notifications_setting.mail).to be_truthy
          expect(updated_notifications_setting.facebook).to be_truthy
          expect(updated_notifications_setting.whatsapp).to be_truthy

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        patch :update, notifications_setting_params

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

require 'spec_helper'

describe Api::V1::TelephoneUpdateRequestsController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'POST #validate' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when there is an update request that matches the given code' do
        let(:telephone_update_request) { FactoryGirl.create(:telephone_update_request, user: user) }

        context 'when the requested telephone number is free' do
          it 'updates the telephone of the user and responds a json with the information of the logged in user' do
            post :validate, validation_code: telephone_update_request.validation_code

            expect(telephone_update_request.reload).to be_applied
            expect(user.reload.telephone).to eq telephone_update_request.telephone

            expect(response).to render_template 'api/v1/users/show'
            expect(response.status).to eq 200
            expect(response_body[:id]).to eq user.id
            expect(response_body[:email]).to eq user.email
            expect(response_body[:nickname]).to eq user.nickname
            expect(response_body[:first_name]).to eq user.first_name
            expect(response_body[:last_name]).to eq user.last_name
            expect(response_body[:telephone]).to eq user.telephone
            expect(response_body[:member_since]).to eq user.created_at.strftime('%d/%m/%Y')
          end
        end

        context 'when the requested telephone number is taken' do
          it 'does not update the telephone of the user and responds a json error' do
            FactoryGirl.create(:user, telephone: telephone_update_request.telephone)

            post :validate, validation_code: telephone_update_request.validation_code

            expect(telephone_update_request).not_to be_applied
            expect(user.telephone).not_to eq telephone_update_request.telephone

            expect(response.status).to eq 400
            expect(response_body[:errors]).to include Api::V1::TelephoneUpdateRequestsController::TELEPHONE_ALREADY_TAKEN
          end
        end
      end

      context 'when no update request matches the given code' do
        it 'responds a json error' do
          post :validate, validation_code: 'invalid_code'

          expect(response.status).to eq 400
          expect(response_body[:errors]).to include Api::V1::TelephoneUpdateRequestsController::MISSING_UPDATE_REQUEST
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :validate, validation_code: 'code'

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

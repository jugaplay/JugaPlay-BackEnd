require 'spec_helper'

describe Api::V1::InvitationRequestsController do
  let(:user) { FactoryGirl.create(:user) }

  describe 'GET #index' do
    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the user has some invitation requests' do
        let!(:invitation_request) { FactoryGirl.create(:invitation_request, user: user) }
        let!(:another_invitation_request) { FactoryGirl.create(:invitation_request, user: user) }

        it 'responds a json with the information of the invitation requests of the user' do
          get :index

          expect(response_body[:invitation_requests]).to have(2).items
          expect(response_body[:invitation_requests].first[:id]).to eq invitation_request.id
          expect(response_body[:invitation_requests].first[:type]).to eq invitation_request.type
          expect(response_body[:invitation_requests].first[:visited]).not_to be_empty
          expect(response_body[:invitation_requests].first[:accepted]).not_to be_empty
          expect(response.status).to eq 200
          expect(response).to render_template :index
        end
      end

      context 'when the user does not have any invitation request' do
        it 'responds a json without invitation requests' do
          get :index

          expect(response_body[:invitation_requests]).to be_empty
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

  describe 'POST #create' do
    context 'when the user is signed in' do
      before { sign_in user }

      context 'when the request type is supported' do
        it 'creates a new invitation request and renders a json of it' do
          expect { post :create, type: InvitationRequestType::WHATSAPP }.to change { InvitationRequest.count }.by 1

          new_invitation_request = InvitationRequest.last
          expect(new_invitation_request.user).to eq user
          expect(new_invitation_request.type).to eq InvitationRequestType::WHATSAPP
          expect(new_invitation_request.invitation_visits).to be_empty
          expect(new_invitation_request.invitation_acceptances).to be_empty

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when the type is not supported' do
        it 'does not create a invitation request and renders a json with error messages' do
          expect { post :create, type: 'bad type' }.to_not change { InvitationRequest.count }

          expect(response.status).to eq 200
          expect(response_body[:errors][:type]).to include "is not included in the list"
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :create, type: 'type'

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end

  describe 'POST #visit' do
    let!(:invitation_request) { FactoryGirl.create(:invitation_request) }

    context 'when the request token exists' do
      it 'creates a new invitation visit, links it to the request and renders a json of it' do
        expect { post :visit, token: invitation_request.token }.to change { InvitationVisit.count }.by 1

        new_invitation_visit = InvitationVisit.last
        expect(new_invitation_visit.ip).not_to be_nil
        expect(new_invitation_visit.invitation_request).to eq invitation_request

        expect(response.status).to eq 200
        expect(response).to render_template :show
      end
    end

    context 'when the type is not supported' do
      it 'does not create a invitation visit and renders a json with error messages' do
        expect { post :visit, token: 'invalid token' }.to_not change { InvitationVisit.count }

        expect(response.status).to eq 200
        expect(response_body[:errors][:invitation_request]).to include "can't be blank"
      end
    end
  end

  describe 'POST #accept' do
    let!(:invitation_request) { FactoryGirl.create(:invitation_request) }

    context 'when the user is logged in' do
      before { sign_in user }

      context 'when the request token exists' do
        it 'creates a new invitation acceptance, links it to the request and renders a json of it' do
          expect { post :accept, token: invitation_request.token }.to change { InvitationAcceptance.count }.by 1

          new_invitation_acceptane = InvitationAcceptance.last
          expect(new_invitation_acceptane.ip).not_to be_nil
          expect(new_invitation_acceptane.user).to eq user
          expect(new_invitation_acceptane.invitation_request).to eq invitation_request

          expect(response.status).to eq 200
          expect(response).to render_template :show
        end
      end

      context 'when the type is not supported' do
        it 'does not create a invitation acceptance and renders a json with error messages' do
          expect { post :accept, token: 'invalid token' }.to_not change { InvitationAcceptance.count }

          expect(response.status).to eq 200
          expect(response_body[:errors][:invitation_request]).to include "can't be blank"
        end
      end
    end

    context 'when the user is not logged in' do
      it 'responds an error json' do
        post :accept, type: 'type'

        expect(response.status).to eq 401
        expect(response_body[:errors]).to include 'You need to sign in or sign up before continuing.'
      end
    end
  end
end

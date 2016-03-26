require 'spec_helper'

describe Api::V1::CommentsController do
  describe 'POST #create' do
    let(:comment_params) do
      {
        comment: {
          sender_name: 'Pedro',
          sender_email: 'p@gmail.com',
          content: 'a new comment'
        }
      }
    end

    context 'when request succeeds' do
      it 'creates a comment' do
        expect { post :create, comment_params }.to change { Comment.count }.by(1)

        new_comment = Comment.last
        expect(new_comment.sender_name).to eq comment_params[:comment][:sender_name]
        expect(new_comment.sender_email).to eq comment_params[:comment][:sender_email]
        expect(new_comment.content).to eq comment_params[:comment][:content]

        expect(response).to render_template :show
        expect(response.status).to eq 200
        expect(response_body[:id]).to eq new_comment.id
        expect(response_body[:sender_name]).to eq new_comment.sender_name
        expect(response_body[:sender_email]).to eq new_comment.sender_email
        expect(response_body[:content]).to eq new_comment.content
      end

      it 'sends a mail with the comment' do
        post :create, comment_params

        comment_mails = CommentsMailer.deliveries
        expect(comment_mails).to have(1).item
        expect(comment_mails.last.to).to include CommentsMailer::COMMENTS_MAIL
        expect(comment_mails.last.from).to include comment_params[:comment][:sender_email]
        expect(comment_mails.last.subject).to eq "New comment from #{comment_params[:comment][:sender_name]}"
        expect(comment_mails.last.body).to eq comment_params[:comment][:content]
      end

      context 'when it does not include sender information' do
        let(:comment_params) { { comment: { content: 'a content' } } }

        it 'creates a comment' do
          expect { post :create, comment_params }.to change { Comment.count }.by(1)

          new_comment = Comment.last
          expect(new_comment.sender_name).to be_nil
          expect(new_comment.sender_email).to be_nil
          expect(new_comment.content).to eq comment_params[:comment][:content]

          expect(response).to render_template :show
          expect(response.status).to eq 200
          expect(response_body[:id]).to eq new_comment.id
          expect(response_body[:sender_name]).to eq nil
          expect(response_body[:sender_email]).to eq nil
          expect(response_body[:content]).to eq new_comment.content
        end
      end
    end

    context 'when the request fails' do
      let(:comment_params) { { comment: { content: content } } }

      context 'when a required parameter is missing' do
        let(:content) { nil }

        it 'does not create a comment and renders a json with error messages' do
          expect { post :create, comment_params }.to_not change { Comment.count }

          expect(response.status).to eq 200
          expect(response_body[:errors][:content]).to include "can't be blank"
        end
      end

      context 'when the content is longer than 2000 characters' do
        let(:content) { 'a' * 2001 }

        it 'does not create a comment and renders a json with error messages' do
          expect { post :create, comment_params }.to_not change { Comment.count }

          expect(response.status).to eq 200
          expect(response_body[:errors][:content]).to include "is too long (maximum is 2000 characters)"
        end
      end

      context 'when the content is blank' do
        let(:content) { '' }

        it 'does not create a comment and renders a json with error messages' do
          expect { post :create, comment_params }.to_not change { Comment.count }

          expect(response.status).to eq 200
          expect(response_body[:errors][:content]).to include "can't be blank"
        end
      end
    end
  end
end

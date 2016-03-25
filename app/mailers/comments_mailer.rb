class CommentsMailer < ActionMailer::Base
  COMMENTS_MAIL = 'comments@jugaplay.com'

  def send_new_comment_message(comment)
    mail to: COMMENTS_MAIL, from: (comment.sender_email || COMMENTS_MAIL),
         subject: "New comment from #{comment.sender_name}" do |format|
      format.text { render text: comment.content }
    end
  end
end

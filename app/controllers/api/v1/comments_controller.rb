class Api::V1::CommentsController < Api::BaseController
  skip_before_filter :authenticate_user!

  def create
    @comment = Comment.new(comment_params)
    return render_json_errors @comment.errors unless @comment.save
    CommentsMailer.send_new_comment_message(@comment).deliver_now
    render :show
  end

  private

  def comment_params
    params.require(:comment).permit(:sender_name, :sender_email, :content)
  end
end

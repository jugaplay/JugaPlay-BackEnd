class Api::V1::ExplanationsController < Api::BaseController
  def index
    @explanations = Explanation.joins(:users).where(users: {id: current_user})
  end

  def create
    @user = User.find(current_user)
    @explanation = Explanation.where(id: params[:explanation_id]).first()

    if @explanation.present? and @user.present?
      @user.explanations<<(@explanation)
      render :show
    else
      return render_json_errors 'explanation_id not found'
    end
  end
end

class Api::V1::ExplanationsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @explanations = Explanation.where(id: params[:user_id])
  end


 def create
 	@user = User.find(params[:user_id])
    @explanation = Explanation.find(params[:explanation_id])
    @user.explanations<<(@explanation)
    render :show
  end

    
end

class Api::V1::ExplanationsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @explanations = Explanation.where(id: current_user)
  end


 def create
 
 	@user = User.find(current_user)
    @explanation = Explanation.find(params[:id])

    if @explanation.present? and @user.present?   
	    @user.explanations<<(@explanation)
    	render :show
    else
     	return render_json_errors 'Explanation not found'
    end
    
  end

    
end

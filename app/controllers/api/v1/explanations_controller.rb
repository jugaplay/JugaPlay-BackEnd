class Api::V1::ExplanationsController < Api::BaseController
#  skip_before_filter :authenticate_user!, only: [:create]

  def index
    @explanations = Explanation.joins(:users).where(users: {id: current_user})
  end


 def create
 
 	@user = User.find(current_user)
    @explanation = Explanation.where(id: params[:explanation_id]).first()

    if @explanation.present? and @user.present?   
	    if not ( @user.explanations.include?(@explanation))
		    @user.explanations<<(@explanation)
	    	render :show
	   	else
	   		return render_json_errors 'The user alredy has this explanation'
	    end
    else
     	return render_json_errors 'Explanation not found'
    end
    
  end

    
end

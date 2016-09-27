class Api::V1::TPrizesController < Api::BaseController
 

	def create
		  @t_prize = TPrize.new(create_t_prizes_params)  
		  return render :show if  @t_prize.save
  		  render_json_errors @t_prize.errors
	end
	
	def index
   		 @t_prizes = TPrize.where(user: current_user).limit(params[:to]).offset(params[:from])
	end 
	  		
	private
	  		
	def create_t_prizes_params
	    t_prizes_params = params.permit(:coins, :detail, :user, :prize)
    end
	  		
end

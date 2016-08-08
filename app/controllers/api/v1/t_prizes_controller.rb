class Api::V1::TPrizesController < Api::BaseController
 

	def create
	
		@prize =  Prize.find_by_id(params[:prize_id])
		
	    @t_prize = TPrize.new(coins: params[:coins],detail: params[:detail], 
	    user: current_user, prize: @prize)
	    	    
		  return render :show if  @t_prize.save
  		  render_json_errors @t_prize.errors
    
	end
	  		
end

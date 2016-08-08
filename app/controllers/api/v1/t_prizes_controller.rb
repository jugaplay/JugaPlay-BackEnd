class Api::V1::TPrizesController < Api::BaseController
 

	def create
			
	    @t_prize = TPrize.new(coins: params[:coins],detail: params[:detail], 
	    user: params[:user], prize: params[:prize])
	    	    
		  return render :show if  @t_prize.save
  		  render_json_errors @t_prize.errors
    
	end
	  		
end

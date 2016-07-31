class Api::V1::TWithdrawsController < Api::BaseController
 

	def create
		
	    @t_withdraw = Transaction.new(coins: params[:coins],detail: params[:detail], user: current_user )
	    
		  return render :show if  @t_withdraw.save
  		  render_json_errors @t_withdraw.errors
    
	end
	  		
end

class Api::V1::TWithdrawsController < Api::BaseController
 

#El controlador TWithdraws se corresponde con el modelo Transactions
#En un futuro se deberia renombrar Transactions por TWithdraws

	def create
		
	    @t_withdraw = Transaction.new(coins: params[:coins],detail: params[:detail], user: current_user )
	    
		  return render :show if  @t_withdraw.save
  		  render_json_errors @t_withdraw.errors
    
	end
	
	def index
   		 @t_withdraws = Transaction.where(user: current_user).limit(params[:to]).offset(params[:from])
	end 
	
	  		
end

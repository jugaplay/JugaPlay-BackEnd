class Api::V1::TransactionsController < Api::BaseController
 
	def create
	    @transaction = Transaction.new(coins: params[:coins],detail: params[:detail], user: current_user)
	    @transaction.save! 
	   	render nothing: true
	end
	  	
    def show
   		 @transactions = Transaction.all
	end  	
	
end

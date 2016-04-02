class Api::V1::TransactionsController < Api::BaseController
 

	def create
	    @transaction = Transaction.new(coins: params[:coins],detail: params[:detail], user: current_user)
	    @transaction.save!  
	end
	  	
    def show
   		 @transactions = Transaction.all
	end  	
	
end

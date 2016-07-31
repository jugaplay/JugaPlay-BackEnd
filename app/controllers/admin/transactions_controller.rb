class Admin::TransactionsController < Admin::BaseController
 
	def index
		 @transactions = Transaction.where(user: current_user) 
	end
	
  
end

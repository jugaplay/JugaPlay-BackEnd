class Admin::TransactionsController < Admin::BaseController
 
	def index
		 @transactions = Transaction.where(user_id: current_user) 
	end
	
  
end

class Api::V1::TransactionsController < Api::BaseController
 

	def create
	    @transaction = Transaction.new(coins: params[:coins],detail: params[:detail], user: current_user)
	    @transaction.save!  
   #  redirect_with_success_message admin_teams_path, 'Transaccion creada'
   #	rescue ActiveRecord::RecordInvalid => error
   # 	render_with_error_message 'admin/teams/new', error
   # render :show
	end
	  	
    def show
   		 @transactions = Transaction.all
	end  	
	
end

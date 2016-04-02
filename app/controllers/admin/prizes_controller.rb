class Admin::PrizesController < Admin::BaseController
 
 	CREATE_SUCCESS_MESSAGE= 'Premio creado'
 	UPDATE_SUCCESS_MESSAGE= 'Premio actualizado'
 	
 	
 	def index
		 @table = Table.find(params[:table_id])
	end
	
	def new
		 @prize = Prize.new
	end

	def create
		 @prize = Prize.new prize_params
 		 @table = Table.find(params[:table_id])
		 @prize.save!		 
		 
		  redirect_with_success_message  admin_table_prizes_path(params[:table_id]), CREATE_SUCCESS_MESSAGE
		  rescue ActiveRecord::RecordInvalid => error
		  render_with_error_message  'new', error
	end
	
	def edit
		@prize = Prize.find(params[:id])
	end
	
	
  def update
    @prize = Prize.find(params[:id])
    @prize.update!(params.require(:prize).permit( :position, :coins))
    redirect_with_success_message admin_table_prizes_path(params[:table_id]), UPDATE_SUCCESS_MESSAGE
  rescue ActiveRecord::RecordInvalid => error
    render_with_error_message 'edit', error
  end
	
	
  def prize_params
    permitted_params = params.require(:prize).permit(:table_id, :position, :coins)
    permitted_params
  end
  
	  
end

class Api::V1::TEntryFeesController < Api::BaseController
 

	def create
		@table = Table.where(id: params[:table_id]).first()
		@tournament = Tournament.where(id: params[:tournament_id]).first()
	    @t_entry_fee = TEntryFee.new(coins: params[:coins],detail: params[:detail], 
	    user: current_user, table: @table, tournament: @tournament)
	    
		  return render :show if  @t_entry_fee.save
  		  render_json_errors @t_entry_fee.errors
    
	end
	
	def index
   		 @t_entry_fees = TEntryFee.all.limit(params[:to]).offset(params[:from])
	end 
	  		
end

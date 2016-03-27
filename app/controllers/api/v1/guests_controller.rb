class Api::V1::GuestsController < Api::BaseController

	def index
		 @users = User.where.not(invited_by_id: nil) 
	end
	
  	def show
   		 @users = User.where(invited_by_id: params[:id])
	end

	
end

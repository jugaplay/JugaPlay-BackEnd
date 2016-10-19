class Api::V1::UserPrizesController < Api::BaseController
	def create
		@user_prize = UserPrize.new(create_user_prizes_params)
		return render :show if  @user_prize.save
		render_json_errors @user_prize.errors
	end
	
	def index
		 @user_prizes = UserPrize.where(user: current_user).limit(params[:to]).offset(params[:from])
	end 
	  		
	private
	  		
	def create_user_prizes_params
		params.permit(:coins, :detail, :user, :prize)
	end
end

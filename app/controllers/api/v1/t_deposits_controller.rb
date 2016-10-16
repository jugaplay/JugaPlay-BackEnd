class Api::V1::TDepositsController < Api::BaseController
	def create
		@t_deposit = TDeposit.new(coins: params[:coins],
															detail: params[:detail],
															user: current_user,
															price: params[:price],
															currency: params[:currency],
															payment_service: params[:payment_service],
															country: params[:country],
															transaction_id: params[:transaction_id],
															operator: params[:operator],
															type: params[:type])

		return render :show if @t_deposit.save
		render_json_errors @t_deposit.errors
	end

	def index
		@t_deposits = TDeposit.where(user: current_user).limit(params[:to]).offset(params[:from])
	end
end

class Api::V1::TransactionsController < Api::BaseController
	def create
		@transaction = Transaction.new(coins: params[:coins],detail: params[:detail], user: current_user)
		return render :show if  @transaction.save
		render_json_errors @transaction.errors
	end

	def show
		@transactions = Transaction.all
	end
end

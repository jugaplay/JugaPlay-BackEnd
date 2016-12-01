class Api::V1::PrizesController < Api::BaseController
	def index
		@prizes = current_user.prizes.page(params[:page])
		@total_items = current_user.prizes.count
	end
end

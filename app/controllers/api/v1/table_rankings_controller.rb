class Api::V1::TableRankingsController < Api::BaseController
	def index
		@table_rankings = current_user.table_rankings.page(params[:page])
		@total_items = current_user.table_rankings.count
	end
end

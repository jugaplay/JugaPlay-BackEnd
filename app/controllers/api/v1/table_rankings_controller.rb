class Api::V1::TableRankingsController < Api::BaseController
	def index
		@table_rankings = current_user.table_rankings.merge(TableRanking.recent_first).page(params[:page])
		@total_items = current_user.table_rankings.count
	end
end

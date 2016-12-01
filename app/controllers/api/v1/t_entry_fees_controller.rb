class Api::V1::TEntryFeesController < Api::BaseController
	def index
		@entry_fees = current_user.t_entry_fees.merge(TEntryFee.by_date).limit(params[:to]).offset(params[:from])
	end
end

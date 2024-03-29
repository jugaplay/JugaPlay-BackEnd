class Api::V1::WalletHistoryController < Api::BaseController
	def index
		 @transactions = Transaction.where(user: current_user).limit(params[:to]).offset(params[:from]).order('created_at DESC' )
		 @t_entry_fees = TEntryFee.where(user: current_user).limit(params[:to]).offset(params[:from]).order('created_at DESC' )
		 @t_deposits = TDeposit.where(user: current_user).limit(params[:to]).offset(params[:from]).order('created_at DESC' )
		 @t_promotions = TPromotion.where(user: current_user).limit(params[:to]).offset(params[:from]).order('created_at DESC' )

		 @total_of_transactions =  Transaction.where(user: current_user).sum("coins")
		 @total_of_t_entry_fees =  TEntryFee.where(user: current_user).sum("coins")
		 @total_of_t_deposits =  TDeposit.where(user: current_user).sum("coins")
		 @total_of_t_promotions =  TPromotion.where(user: current_user).sum("coins")

		 @last_month_transactions =  Transaction.where(user: current_user).where(['created_at > ?', DateTime.now - 30.days]).sum('coins')
		 @last_month_t_entry_fees =  TEntryFee.where(user: current_user).where(['created_at > ?', DateTime.now - 30.days]).sum('coins')
		 @last_month_t_deposits =  TDeposit.where(user: current_user).where(['created_at > ?', DateTime.now - 30.days]).sum('coins')
		 @last_month_t_promotions =  TPromotion.where(user: current_user).where(['created_at > ?', DateTime.now - 30.days]).sum('coins')

		 @table_rankings = TableRanking.by_user(current_user).limit(params[:to]).offset(params[:from]).order('table_rankings.created_at DESC' )
		 @total_earned_coins =  TableRanking.by_user(current_user).where(prize_type: Money::COINS).sum('prize_value')
		 @last_month_earned_coins =  TableRanking.by_user(current_user).where(prize_type: Money::COINS).where(['table_rankings.created_at > ?', DateTime.now - 30.days]).sum('prize_value')
	end
end

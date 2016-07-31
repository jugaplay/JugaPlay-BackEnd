class Api::V1::WalletHistoryController < Api::BaseController
 	  	
    def index
   		 @t_entry_fees = TEntryFee.where(user: current_user)
   		 @transactions = Transaction.where(user: current_user)
   		 @t_deposits = TDeposit.where(user: current_user)
   		 @t_prizes = TPrize.where(user: current_user)
	end  	
	
end

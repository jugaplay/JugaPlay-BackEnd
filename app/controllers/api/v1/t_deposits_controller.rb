class Api::V1::TDepositsController < Api::BaseController
 

	def create
	
		@currency =  Currency.find_by_name(params[:currency])
		@payment_service =  PaymentService.find_by_name(params[:payment_service])
		@country = Country.find_by_name(params[:country])
		
	    @t_deposit = TDeposit.new(coins: params[:coins],detail: params[:detail], 
	    user: current_user, price: params[:price] , currency: @currency , payment_service: @payment_service , country: @country )
	    
		  return render :show if  @t_deposit.save
  		  render_json_errors @t_deposit.errors
    
	end
	  		
end

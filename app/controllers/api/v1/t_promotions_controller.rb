class Api::V1::TPromotionsController < Api::BaseController
 
	def create
		
	    @t_promotion = TPromotion.new(promotion_type: params[:promotion_type], coins: params[:coins],detail: params[:detail], user: current_user )	    
		  return render :show if  @t_promotion.save
  		  render_json_errors @t_promotion.errors
    
	end
	
	def index
   		 @t_promotions = TPromotion.where(user: current_user).limit(params[:to]).offset(params[:from])
	end 
	
	  		
end

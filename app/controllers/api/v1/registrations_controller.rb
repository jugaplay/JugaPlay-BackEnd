class Api::V1::RegistrationsController < Api::BaseController

  def index
    @requests = Request.where(host_user_id: params[:user_id])
  end
  
  def show
	 @request = Request.find(params[:id])
  end
  
  def create
  	
	@request = Request.find(params[:request_id])
	@registration_status = RegistrationStatus.find(params[:registration_status_id])
	if params[:guest_user_id].present?
	 @guest_user = User.find(params[:guest_user_id])
	end
    @registration = Registration.create(registration_status:@registration_status , request: @request, won_coins: params[:won_coins], guest_user: @guest_user)
    render :show
  
  end

  
end

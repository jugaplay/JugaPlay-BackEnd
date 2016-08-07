class Api::V1::InvitationsController < ApplicationController

  def index
    @requests = Request.where(host_user_id: params[:user_id])
  end
  
  def show
	 @request = Request.find(params[:id])
  end
  
  def create

	@request = Request.where(id: params[:request_id]).first()
	@invitation_status = InvitationStatus.where(name: params[:invitation_status]).first()
    @invitation = Invitation.new(invitation_status:@invitation_status , request: @request, won_coins: params[:won_coins], guest_user: @guest_user, detail: params[:detail])
	
    	return render :show if @invitation.save
        render json: { errors: @invitation.errors }
  
  end

  def update
    
    @invitation = Invitation.where(id: params[:id]).first()
    
    if(@invitation.present?)
    
    if params[:guest_user_id].present?
	 @guest_user = User.find(params[:guest_user_id])
	 if params[:won_coins].present?
    	 @request.host_user.win_coins!(params[:won_coins])
     end
     @invitation.status = InvitationStatus.where(name: "Registered").first()
	end
	
    return render :show if @invitation.update(update_invitation_params)
    
    render_json_errors @invitation.errors
    else
    
        render json: { errors: 'Invalid invitation_id' }
    
    
    end
    
    
  end
  
  

private

  def update_invitation_params
    params.permit(:won_coins, :detail, :guest_ip, :guest_user_id, :invitation_status_id)
  end
  
end

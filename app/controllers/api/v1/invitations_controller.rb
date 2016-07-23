class Api::V1::InvitationsController < Api::BaseController

  def index
    @requests = Request.where(host_user_id: params[:user_id])
  end
  
  def show
	 @request = Request.find(params[:id])
  end
  
  def create

	@request = Request.find(params[:request_id])
	@invitation_status = InvitationStatus.find(params[:invitation_status_id])
	
	if params[:guest_user_id].present?
	 @guest_user = User.find(params[:guest_user_id])
	 if params[:won_coins].present?
    	 @request.host_user.win_coins!(params[:won_coins])
     end
	end

    
    @invitation = Invitation.create(invitation_status:@invitation_status , request: @request, won_coins: params[:won_coins], guest_user: @guest_user, detail: params[:detail])
	
    	return render :show if(@invitation.valid?)
        render_json_errors @invitation.errors   
  
  end

  def update
  # TODO patron de estados - solo debe permitir pasar de estado unused -> entered -> registered
    @invitation = Invitation.find(params[:id])
    return render :show if @invitation.update(update_invitation_params)
    render_json_errors @invitation.errors
  end
  
  

private

  def update_invitation_params
    params.require(:invitation).permit(:won_coins, :detail, :guest_ip, :guest_user_id, :invitation_status_id)
  end
  
end

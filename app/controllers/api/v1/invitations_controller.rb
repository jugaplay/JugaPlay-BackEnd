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
end

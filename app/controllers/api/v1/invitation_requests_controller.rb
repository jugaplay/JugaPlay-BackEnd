class Api::V1::InvitationRequestsController < Api::BaseController
  INVALID_INVITATION_TOKEN = 'No existe una invitación con el token indicado'
  skip_before_filter :authenticate_user!, only: [:visit]

  def index
    @invitation_requests = current_user.invitation_requests
  end

  def create
    @invitation_request = new_invitation_request
    return render :show if invitation_request.save
    render_json_errors invitation_request.errors
  end

  def visit
    return render_json_error INVALID_INVITATION_TOKEN if invitation_request.nil?
    invitation_request.visit(remote_ip)
    return render :show if invitation_request.save
    render_json_errors invitation_request.errors
  end

  def accept
    return render_json_error INVALID_INVITATION_TOKEN if invitation_request.nil?
    invitation_request.accept(current_user, remote_ip)
    return render :show if invitation_request.save
    render_json_errors invitation_request.errors
  end

  private

  def new_invitation_request
    InvitationRequest.new(type: params[:type], user: current_user, token: Devise.friendly_token(32))
  end

  def remote_ip
    request.remote_ip || '0.0.0.0'
  end

  def invitation_request
    @invitation_request ||= InvitationRequest.find_by_token(params[:token])
  end
end

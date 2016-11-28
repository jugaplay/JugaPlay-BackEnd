class Api::V1::InvitationRequestsController < Api::BaseController
  skip_before_filter :authenticate_user!, only: [:visit]

  def index
    @invitation_requests = current_user.invitation_requests
  end

  def create
    @invitation_request = new_invitation_request
    return render :show if @invitation_request.save
    render_json_errors @invitation_request.errors
  end

  def visit
    invitation_visit = new_invitation_visit
    return render :show if invitation_visit.save
    render_json_errors invitation_visit.errors
  end

  def accept
    invitation_acceptance = new_invitation_acceptance
    return render_json_errors invitation_acceptance.errors unless invitation_acceptance.save
    give_coins_to_inviting_user
    create_notification
    render :show
  end

  private

  def new_invitation_visit
    InvitationVisit.new(invitation_request: invitation_request, ip: remote_ip)
  end

  def new_invitation_acceptance
    InvitationAcceptance.new(invitation_request: invitation_request, ip: remote_ip, user: current_user)
  end

  def new_invitation_request
    InvitationRequest.new(type: params[:type], user: current_user, token: Devise.friendly_token(32))
  end

  def give_coins_to_inviting_user
    TPromotion.friend_invitation!(user: invitation_request.user, detail: "Invitación a #{current_user.nickname}")
  end

  def create_notification
    text = Wallet::COINS_PER_INVITATION.to_s
    title = "<b>#{current_user.nickname}</b> aceptó tu invitación"
    Notification.friend_invitation!(user: invitation_request.user, title: title, text: text)
  end

  def remote_ip
    request.remote_ip || '0.0.0.0'
  end

  def invitation_request
    @invitation_request ||= InvitationRequest.find_by_token(params[:token])
  end
end

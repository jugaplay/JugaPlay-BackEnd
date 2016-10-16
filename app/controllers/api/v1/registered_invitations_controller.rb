class Api::V1::RegisteredInvitationsController < Api::BaseController
	def index
		@registered_invitations = []
		@invitation_status = InvitationStatus.find_by_name('Registered')
		@requests = Request.where(host_user: current_user)
		@requests.each do |request|
			invitations = invitation.where(invitation_status: @invitation_status, request_id: request.id)
			invitations.each do |invitation|
				@registered_invitations  << invitation
			end
		end
	end
end

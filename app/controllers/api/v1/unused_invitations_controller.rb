class Api::V1::UnusedInvitationsController < Api::BaseController


	def index
		@unused_invitations = [] 
		@invitation_status = InvitationStatus.find_by_name('Unused')
		@requests = Request.where(host_user: current_user) 
		@requests.each do |request|
			invitations = Invitation.where(invitation_status: @invitation_status, request_id: request.id)
			invitations.each do |invitation|
				@unused_invitations  << invitation
			end
		end	
	end
	
	
end

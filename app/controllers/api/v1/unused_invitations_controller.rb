class Api::V1::UnusedInvitationsController < Api::BaseController


	def index
		@unused_invitations = [] 
		@registration_status = RegistrationStatus.find_by_name('Unused')
		@requests = Request.where(host_user: current_user) 
		@requests.each do |request|
			registrations = Registration.where(registration_status: @registration_status, request_id: request.id)
			registrations.each do |registration|
				@unused_invitations  << registration
			end
		end	
	end
	
	
end

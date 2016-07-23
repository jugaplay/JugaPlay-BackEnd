class Api::V1::RegisteredInvitationsController < Api::BaseController


	def index
		@registered_invitations = [] 
		@registration_status = RegistrationStatus.find_by_name('Registered')
		@requests = Request.where(host_user: current_user) 
		@requests.each do |request|
			registrations = Registration.where(registration_status: @registration_status, request_id: request.id)
			registrations.each do |registration|
				@registered_invitations  << registration
			end
		end	
	end
	
	
end

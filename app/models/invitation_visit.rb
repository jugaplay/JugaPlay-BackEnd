class InvitationVisit < ActiveRecord::Base
	belongs_to :invitation_request

	validates :ip, presence: true
	validates :invitation_request, presence: true
end

class InvitationAcceptance < ActiveRecord::Base
	belongs_to :user
	belongs_to :invitation_request

	validates :ip, presence: true
	validates :invitation_request, presence: true
	validates :user, presence: true, uniqueness: { scope: :invitation_request }
	validate :validate_not_accepted_by_himself, on: :update

	private

	def validate_not_accepted_by_himself
		errors.add(:user, 'Can not invite himself') if user.present? && user.eql?(invitation_request.user)
	end
end

json.array! @registered_invitations do |registered_invitation|
	json.id registered_invitation.id
	json.status registered_invitation.invitation_status.name
	json.detail registered_invitation.detail
	json.won_coins registered_invitation.won_coins
	json.request_id registered_invitation.request.id
	json.guest_user registered_invitation.guest_user

end

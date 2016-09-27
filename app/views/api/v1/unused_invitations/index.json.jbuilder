json.array! @unused_invitations do |unused_invitation|
	json.id unused_invitation.id
	json.status unused_invitation.invitation_status.name
	json.detail unused_invitation.detail
	json.won_coins unused_invitation.won_coins
	json.request_id unused_invitation.request.id
	json.guest_user unused_invitation.guest_user

end

class RemoveRequestsAndInvitations < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      invitations_data = ActiveRecord::Base.connection.execute('SELECT * from invitations inner join invitation_statuses ON invitations.invitation_status_id = invitation_statuses.id')
      invitations_data.each do |invitation_data|
        ip = invitation_data['guest_ip'] || '0.0.0.0'
        if invitation_data['name'].eql? 'Entered'
          InvitationAcceptance.create!(user_id: invitation_data['guest_user_id'], invitation_request_id: invitation_data['request_id'], ip: ip, created_at: invitation_data['created_at'], updated_at: invitation_data['updated_at'])
        else
          InvitationVisit.create!(invitation_request_id: invitation_data['request_id'], ip: ip, created_at: invitation_data['created_at'], updated_at: invitation_data['updated_at'])
        end
      end

      User.where.not(invited_by_id: nil).each do |user|
        acceptance = InvitationAcceptance.joins(:invitation_request).where(user_id: user.id).where(invitation_requests: { user_id: user.invited_by_id })
        unless acceptance.present?
          invitation_request = InvitationRequest.find_by_user_id(user.invited_by_id)
          if invitation_request.nil?
            invitation_request = InvitationRequest.create!(user_id: user.invited_by_id, type: InvitationRequestType::LINK, token: Devise.friendly_token(32))
          end
          puts "Creando aceptacion de invitacion para el usuario #{user.name} con request #{invitation_request.id}"
          InvitationAcceptance.create!(user: user, invitation_request: invitation_request, ip: '0.0.0.0')
        end
      end
    end

    drop_table :invitations
    drop_table :invitation_statuses
    remove_column :users, :invited_by_id
  end
end

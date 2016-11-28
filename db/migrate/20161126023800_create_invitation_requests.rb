class CreateInvitationRequests < ActiveRecord::Migration
  def change
    rename_table :requests, :invitation_requests
    rename_column :invitation_requests, :host_user_id, :user_id
    change_column :invitation_requests, :user_id, :integer, null: false
    add_column :invitation_requests, :token, :string

    types_data = ActiveRecord::Base.connection.execute('SELECT * from request_types')
    add_column :invitation_requests, :type, :string
    InvitationRequest.find_each do |invitation_request|
      type_data_for_request = types_data.detect(InvitationRequestType::LINK) { |type_data| type_data['id'].to_i.eql? invitation_request.request_type_id }
      invitation_request.update_attributes(type: type_data_for_request['name'])
    end
    change_column :invitation_requests, :type, :string, null: false, default: InvitationRequestType::LINK
    change_column :invitation_requests, :type, :string, null: false
    remove_column :invitation_requests, :request_type_id
    drop_table :request_types

    InvitationRequest.find_each do |invitation_request|
      if invitation_request.user.nil?
        invitation_request.delete
      else
        invitation_request.update_attributes!(token: Devise.friendly_token(32))
      end
    end

    change_column :invitation_requests, :token, :string, null: false
    add_index :invitation_requests, :token, unique: true
  end
end

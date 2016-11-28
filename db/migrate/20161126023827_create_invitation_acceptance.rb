class CreateInvitationAcceptance < ActiveRecord::Migration
  def change
    create_table :invitation_acceptances do |t|
      t.references :invitation_request, null: false, index: true
      t.references :user, null: false, index: true
      t.inet :ip, null: false

      t.timestamps
      t.index [:user_id, :invitation_request_id], unique: true, name: 'unique_user_per_invitation_request'
    end
  end
end

class CreateGroupInvitationTokenToGroups < ActiveRecord::Migration
  def change
    create_table :group_invitation_tokens do |t|
      t.references :group, null: false, index: true
      t.string :token, null: false, unique: true, index: true
      t.datetime :expires_at, null: false
      t.timestamps
    end

    Group.all.each do |group|
      GroupInvitationToken.create_for_group!(group).save!
    end
  end
end

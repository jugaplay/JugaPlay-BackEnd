class AddUniqueIndexesToGroupInvitationTokens < ActiveRecord::Migration
  def up
    remove_index :group_invitation_tokens, :token
    remove_index :group_invitation_tokens, :group_id
    add_index :group_invitation_tokens, :token, unique: true
    add_index :group_invitation_tokens, :group_id, unique: true
  end

  def down
    remove_index :group_invitation_tokens, :token
    remove_index :group_invitation_tokens, :group_id
    add_index :group_invitation_tokens, :token
    add_index :group_invitation_tokens, :group_id
  end
end

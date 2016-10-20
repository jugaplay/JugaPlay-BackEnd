class RenameUserUidForFacebookId < ActiveRecord::Migration
  def change
    rename_column :users, :uid, :facebook_id
  end
end

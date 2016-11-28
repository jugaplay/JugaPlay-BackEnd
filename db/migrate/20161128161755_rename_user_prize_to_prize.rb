class RenameUserPrizeToPrize < ActiveRecord::Migration
  def change
    rename_table :user_prizes, :prizes
  end
end

class AddGroupToTables < ActiveRecord::Migration
  def change
    add_reference :tables, :group
  end
end

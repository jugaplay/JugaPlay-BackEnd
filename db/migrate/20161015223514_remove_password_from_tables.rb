class RemovePasswordFromTables < ActiveRecord::Migration
  def change
    remove_column :tables, :has_password
  end
end

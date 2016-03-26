class AddOpenStatusToTables < ActiveRecord::Migration
  def change
    add_column :tables, :opened, :boolean, null: false, default: true
  end
end

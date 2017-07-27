class AddTypeToPlays < ActiveRecord::Migration
  def up
    add_column :plays, :type_cd, :integer, null: true
    ActiveRecord::Base.connection.execute("UPDATE plays SET type_cd = '#{Play.types[:league]}' FROM tables WHERE plays.table_id = tables.id AND group_id IS NULL")
    ActiveRecord::Base.connection.execute("UPDATE plays SET type_cd = '#{Play.types[:challenge]}' FROM tables WHERE plays.table_id = tables.id AND group_id IS NOT NULL")
    change_column :plays, :type_cd, :integer, null: false
  end

  def down
    remove_column :plays, :type_cd
  end
end

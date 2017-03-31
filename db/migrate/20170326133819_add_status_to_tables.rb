class AddStatusToTables < ActiveRecord::Migration
  def up
    add_column :tables, :status_cd, :integer, null: true

    tables_data = ActiveRecord::Base.connection.execute('SELECT id, opened FROM tables')
    table_statuses = tables_data.map do |table_data|
      status = table_data['opened'] ? Table.statuses[:opened] : Table.statuses[:closed]
      { status_cd: status }
    end
    tables_ids = tables_data.map { |table_data| table_data['id'] }
    Table.update(tables_ids, table_statuses)

    change_column :tables, :status_cd, :integer, null: false
    remove_column :tables, :opened
  end

  def down
    add_column :tables, :opened, :boolean

    tables_data = ActiveRecord::Base.connection.execute('SELECT id, status_cd FROM tables')
    table_opened = tables_data.map do |table_data|
      { opened: table_data['status_cd'].eql?(Table.statuses[:opened]) }
    end
    tables_ids = tables_data.map { |table_data| table_data['id'] }
    Table.update(tables_ids, table_opened)

    change_column :tables, :opened, :boolean, null: false
    remove_column :tables, :status_cd
  end
end

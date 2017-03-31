class AddStatusToTables < ActiveRecord::Migration
  def up
    add_column :tables, :status_cd, :integer, null: true

    tables_data = ActiveRecord::Base.connection.execute('SELECT id, opened FROM tables')
    tables_data.to_a.in_groups_of(200, false) do |tables_data_group|
      puts "Setting status for a subgroup of #{tables_data_group.count} tables"
      queries = tables_data_group.map do |table_data|
        status = table_data['opened'] ? Table.statuses[:opened] : Table.statuses[:closed]
        "UPDATE tables SET status_cd = #{status} WHERE id = #{table_data['id']}"
      end
      ActiveRecord::Base.connection.execute(queries.join('; '))
    end

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

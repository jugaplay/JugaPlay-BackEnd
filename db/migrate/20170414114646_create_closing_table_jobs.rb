class CreateClosingTableJobs < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute('DELETE FROM delayed_jobs')

    create_table :closing_table_jobs do |t|
      t.references :table, null: false
      t.integer :priority, null: false, unique: true
      t.integer :status_cd, null: false
      t.datetime :stopped_at, null: true
      t.string :error_message, null: true
      t.timestamps

      t.index :table_id, unique: true
    end
  end
end

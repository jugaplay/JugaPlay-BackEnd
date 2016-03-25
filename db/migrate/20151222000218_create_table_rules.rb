class CreateTableRules < ActiveRecord::Migration
  def change
    create_table :table_rules do |t|
      t.references :table, null: false
      t.float :goals, null: false, default: 0.0
      t.float :passes, null: false, default: 0.0

      t.timestamps
    end

    add_index :table_rules, :table_id, unique: true
  end
end

class CreateTableWinners < ActiveRecord::Migration
  def change
    create_table :table_winners do |t|
      t.references :table, null: false
      t.references :user, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end

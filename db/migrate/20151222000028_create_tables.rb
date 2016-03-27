class CreateTables < ActiveRecord::Migration
  def change
    create_table :tables do |t|
      t.string :title, null: false
      t.boolean :has_password, null: false, default: false
      t.integer :number_of_players, null: false, default: 1
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.text :description, null: false
      t.text :points_for_winners, null: false
      t.timestamps
    end

    add_index :tables, [:title, :start_time, :end_time], unique: true
  end
end

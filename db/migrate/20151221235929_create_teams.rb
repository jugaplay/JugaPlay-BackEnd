class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, null: false, unique: true
      t.references :director, null: false
      t.text :description, null: false

      t.timestamps
    end

    add_index :teams, :name, unique: true
    add_index :teams, :director_id, unique: true
  end
end

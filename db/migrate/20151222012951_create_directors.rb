class CreateDirectors < ActiveRecord::Migration
  def change
    create_table :directors do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.text :description, null: false

      t.timestamps
    end

    add_index :directors, :first_name
    add_index :directors, :last_name
  end
end

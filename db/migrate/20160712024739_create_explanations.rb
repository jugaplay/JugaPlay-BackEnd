class CreateExplanations < ActiveRecord::Migration
  def change
    create_table :explanations do |t|
      t.string :name
      t.text :detail

      t.timestamps null: false
    end
  end
end

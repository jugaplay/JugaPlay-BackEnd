class CreateExplanations < ActiveRecord::Migration
  def change
    create_table :explanations do |t|
      t.string :name
      t.text :detail

      t.timestamps null: false
    end
    
    add_index :explanations, :name, unique: true
     
     
  end
end

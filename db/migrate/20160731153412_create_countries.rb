class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name
      t.references :language, index: true, foreign_key: true

      t.timestamps null: false
    end
    
    add_index :countries, :name, unique: true
    
  end
end

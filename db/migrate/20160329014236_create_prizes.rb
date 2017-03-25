class CreatePrizes < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.integer :coins
      t.integer :position
  	  t.references :table
      t.timestamps null: false
    end
  end
end

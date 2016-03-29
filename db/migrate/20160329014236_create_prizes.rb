class CreatePrizes < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.integer :coins
      t.integer :position
	  t.references :user
      t.timestamps null: false
    end
  end
end

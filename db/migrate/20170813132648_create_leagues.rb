class CreateLeagues < ActiveRecord::Migration
  def change
    create_table :leagues do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.string :image, null: false
      t.text :prizes_values, null: false
      t.string :prizes_type, null: false
      t.integer :status_cd, null: false
      t.integer :frequency_in_days, null: false
      t.integer :periods, null: false

      t.timestamps
    end
  end
end

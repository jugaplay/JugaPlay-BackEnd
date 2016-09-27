class CreateTPromotions < ActiveRecord::Migration
  def change
    create_table :t_promotions do |t|
      t.integer :coins
      t.string :detail
      t.string :promotion_type
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

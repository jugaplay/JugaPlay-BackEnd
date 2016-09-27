class CreateTPrizes < ActiveRecord::Migration
  def change
    create_table :t_prizes do |t|
      t.integer :coins
      t.references :user, index: true, foreign_key: true
      t.string :detail
      t.references :prize, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end

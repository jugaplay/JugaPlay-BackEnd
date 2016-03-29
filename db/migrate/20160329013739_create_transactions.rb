class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.integer :coins
      t.string :detail
      t.references :user

      t.timestamps null: false
    end
  end
end

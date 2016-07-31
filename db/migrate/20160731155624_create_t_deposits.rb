class CreateTDeposits < ActiveRecord::Migration
  def change
    create_table :t_deposits do |t|
      t.integer :coins
      t.references :user, index: true, foreign_key: true
      t.string :detail
      t.references :currency, index: true, foreign_key: true
      t.references :country, index: true, foreign_key: true
      t.references :payment_service, index: true, foreign_key: true
      t.string :transaction_id
      t.float :price
      t.string :operator
      t.string :type
      t.string :detail

      t.timestamps null: false
    end
  end
end

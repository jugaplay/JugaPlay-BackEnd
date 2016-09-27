class CreatePaymentServices < ActiveRecord::Migration
  def change
    create_table :payment_services do |t|
      t.string :name

      t.timestamps null: false
    end
    
    add_index :payment_services, :name, unique: true
    
  end
end

class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :won_coins
      t.inet :guest_ip
      t.references :registration_status, null: false
      t.references :request, null: false
      t.references :guest_user, null: false

      t.timestamps null: false
    end
    
    add_index :registrations, [:guest_user_id, :request_id], unique: true
          
  end
  
end

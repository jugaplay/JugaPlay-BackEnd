class CreateRegistrations < ActiveRecord::Migration
  def change
    create_table :registrations do |t|
      t.integer :won_coins
      t.inet :guest_ip
      t.string: detail
      t.references :registration_status, null: false
      t.references :request, null: false
      t.references :guest_user, null: true
	
      t.timestamps null: false
    end
              
  end
  
end

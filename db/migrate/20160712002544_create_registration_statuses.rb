class CreateRegistrationStatuses < ActiveRecord::Migration
  def change
    create_table :registration_statuses do |t|
      t.string :name

      t.timestamps null: false
    end
    
    add_index :registration_statuses, :name, unique: true
     
     
  end
end

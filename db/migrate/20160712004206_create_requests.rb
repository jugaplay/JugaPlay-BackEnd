class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
    
      t.references :request_type, null: false
      t.references :host_user, null: false
      t.timestamps null: false
    end
    
    add_index :requests, :request_type_id
    add_index :requests, :host_user_id
     
     
  end
end


class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :won_coins
      t.inet :guest_ip
      t.references :request_status, null: false
      t.references :request_types, null: false
      t.references :host_user, null: false
      t.references :guest_user, null: false

      t.timestamps null: false
    end
  end
end


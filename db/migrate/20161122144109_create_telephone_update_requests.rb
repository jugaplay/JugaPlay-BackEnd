class CreateTelephoneUpdateRequests < ActiveRecord::Migration
  def change
    create_table :telephone_update_requests do |t|
      t.references :user, null: false, index: true
      t.string :telephone, null: false
      t.string :validation_code, null: false, index: true
      t.boolean :applied, null: false, default: false
    end

    add_index :telephone_update_requests, [:user_id, :validation_code], unique: true
  end
end

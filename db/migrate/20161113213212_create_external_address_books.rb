class CreateExternalAddressBooks < ActiveRecord::Migration
  def change
    create_table :external_address_books do |t|
      t.references :user, null: false, index: true
      t.string :email
      t.string :phone
      t.timestamps

      t.index [:user_id, :email], unique: true
      t.index [:user_id, :phone], unique: true
    end
  end
end

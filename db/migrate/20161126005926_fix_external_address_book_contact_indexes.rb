class FixExternalAddressBookContactIndexes < ActiveRecord::Migration
  def change
    remove_index :external_address_book_contacts, [:user_id, :email]
    remove_index :external_address_book_contacts, [:user_id, :phone]
    add_index :external_address_book_contacts, [:user_id, :email, :phone], unique: true, name: 'unique_email_and_phone_per_user'
  end
end

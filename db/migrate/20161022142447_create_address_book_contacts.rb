class CreateAddressBookContacts < ActiveRecord::Migration
  def change
    rename_table :address_books_users, :address_book_contacts

    add_column :address_book_contacts, :nickname, :string, null: false
    add_column :address_book_contacts, :synched_by_email, :boolean, null: false, default: false
    add_column :address_book_contacts, :synched_by_facebook, :boolean, null: false, default: false
  end
end

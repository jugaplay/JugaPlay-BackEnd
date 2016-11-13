class RenameExternalAddressBookToExternalAddressBookContact < ActiveRecord::Migration
  def change
    rename_table :external_address_books, :external_address_book_contacts
  end
end

class AddNameToExternalAddressBookContacts < ActiveRecord::Migration
  def change
    add_column :external_address_book_contacts, :name, :string, default: ''
  end
end

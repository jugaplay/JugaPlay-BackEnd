class AddSynchedByPhoneToAddressBookContact < ActiveRecord::Migration
  def change
    add_column :address_book_contacts, :synched_by_phone, :boolean, default: false
  end
end

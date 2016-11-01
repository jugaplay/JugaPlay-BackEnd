class CreateAddressBook < ActiveRecord::Migration
  def change
    create_table :address_books do |t|
      t.references :user, null: false
      t.timestamps

      t.index :user_id, unique: true
    end

    create_table :address_books_users do |t|
      t.references :address_book, null: false
      t.references :user, null: false
      t.timestamps

      t.index [:address_book_id, :user_id], unique: true
    end

    books = User.all.map { |user| AddressBook.new(user: user, contacts: []) }
    AddressBook.import(books)
  end
end

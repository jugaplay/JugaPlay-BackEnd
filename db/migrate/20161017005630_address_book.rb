class AddressBook < ActiveRecord::Migration
  def up
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

    User.find_each do |user|
      user.address_book = AddressBook.create!
    end
  end

  def down
    drop_table :address_books_users
    drop_table :address_books
  end
end

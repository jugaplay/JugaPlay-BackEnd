class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.references :user
      t.integer :coins, null: false, default: 10
      t.integer :credits, null: false, default: 0
      t.timestamps
    end

    add_index :wallets, :user_id, unique: true

    User.all.each { |user| Wallet.create!(user: user) }
  end
end

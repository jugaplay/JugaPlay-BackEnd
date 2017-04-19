class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.references :user
      t.integer :coins, null: false, default: 10
      t.timestamps
    end

    add_index :wallets, :user_id, unique: true

    User.all.each { |user| Wallet.create!(user: user, coins: Wallet::COINS_PER_REGISTRATION) }
  end
end

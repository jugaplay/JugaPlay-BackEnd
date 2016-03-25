class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.references :user
      t.integer :coins, null: false, default: 40

      t.timestamps
    end

    add_index :wallets, :user_id, unique: true

    User.all.each { |user| Wallet.create!(user: user) }
  end
end

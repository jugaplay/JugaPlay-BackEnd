class RemoveDefaultCoinsFromWallets < ActiveRecord::Migration
  def change
    change_column :wallets, :coins, :integer, null: false, default: 0
  end
end

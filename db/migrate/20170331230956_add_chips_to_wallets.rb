class AddChipsToWallets < ActiveRecord::Migration
  def change
    add_column :wallets, :chips, :float, default: 0, null: false
  end
end

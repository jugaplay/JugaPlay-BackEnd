class AddUniqueIndexToUserPrizes < ActiveRecord::Migration
  def change
    Prize.find_each do |prize|
      prizes = Prize.where(table_id: prize.table_id, user_id: prize.user_id)
      if prizes.many?
        total_coins = prizes.pluck(:coins).sum
        prize = prizes.first
        prizes[1..-1].each(&:destroy)
        puts "Actualizando los premios del usuario #{prize.user_id} con monedas #{prize.coins} a #{total_coins}"
        prize.update_attributes(coins: total_coins)
      end
    end

    add_index :user_prizes, [:table_id, :user_id], unique: true
  end
end

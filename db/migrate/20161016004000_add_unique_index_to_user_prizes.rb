class AddUniqueIndexToUserPrizes < ActiveRecord::Migration
  def change
    UserPrize.find_each do |user_prize|
      user_prizes = UserPrize.where(table_id: user_prize.table_id, user_id: user_prize.user_id)
      if user_prizes.many?
        total_coins = user_prizes.pluck(:coins).sum
        user_prize = user_prizes.first
        user_prizes[1..-1].each(&:destroy)
        puts "Actualizando los premios del usuario #{user_prize.user_id} con monedas #{user_prize.coins} a #{total_coins}"
        user_prize.update_attributes(coins: total_coins)
      end
    end

    add_index :user_prizes, [:table_id, :user_id], unique: true
  end
end

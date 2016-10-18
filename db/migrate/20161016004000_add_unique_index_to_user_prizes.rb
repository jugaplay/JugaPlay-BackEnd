class AddUniqueIndexToUserPrizes < ActiveRecord::Migration
  def change
    UserPrize.find_each do |user_prize|
      user_prizes = UserPrize.where(table_id: user_prize.table_id, user_id: user_prize.user_id)
      user_prizes[1..-1].each(&:destroy) if user_prizes.many?
    end

    add_index :user_prizes, [:table_id, :user_id], unique: true
  end
end

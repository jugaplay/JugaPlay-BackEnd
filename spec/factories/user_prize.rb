FactoryGirl.define do
  factory :user_prize do
    user
    table

    after :build do |user_prize|
      user_prize.table.coins_for_winners = [100, 50, 20] if user_prize.table.coins_for_winners.empty?
      user_prize.coins = user_prize.table.coins_for_winners[user_prize.position - 1] if user_prize.coins.nil?
    end
  end
end

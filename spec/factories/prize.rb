FactoryGirl.define do
  factory :prize do
    user
    table

    after :build do |prize|
      prize.table.coins_for_winners = [100, 50, 20] if prize.table.coins_for_winners.empty?
      prize.coins = 100 if prize.coins.nil?
    end
  end
end

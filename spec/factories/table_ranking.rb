FactoryGirl.define do
  factory :table_ranking do
    play
    points { 0 }
    earned_coins { 0 }
    position { TableRanking.last.nil? ? 1 : (TableRanking.last.position + 1) }
    created_at { DateTime.now }

    trait :for_user_and_table do
      ignore do
        user nil
        table nil
      end

      after(:build) do |table_ranking, evaluator|
        table_ranking.play = FactoryGirl.create(:play, user: evaluator.user, table: evaluator.table)
      end
    end

    trait :for_user do
      ignore do
        user nil
      end

      after(:build) do |table_ranking, evaluator|
        table_ranking.play = FactoryGirl.create(:play, user: evaluator.user)
      end
    end
  end
end

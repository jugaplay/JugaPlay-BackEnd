FactoryGirl.define do
  factory :table_ranking do
    play
    points { 0 }
    prize { 0.coins }
    position { TableRanking.last.nil? ? 1 : (TableRanking.last.position + 1) }
    created_at { DateTime.now }

    after :create do |table_ranking|
      table_ranking.update_attributes!(prize: table_ranking.play.training? ?
        Money.new(table_ranking.play.table.entry_cost_type, table_ranking.prize_value) :
        Money.new(table_ranking.play.table.prizes_type, table_ranking.prize_value))
    end

    trait :playing_league do
      transient do
        user nil
        table nil
      end

      after(:build) do |table_ranking, evaluator|
        table_ranking.play = FactoryGirl.create(:play, :league, user: evaluator.user, table: evaluator.table)
      end
    end

    trait :training do
      transient do
        user nil
        table nil
      end

      after(:build) do |table_ranking, evaluator|
        table_ranking.play = FactoryGirl.create(:play, :training, user: evaluator.user, table: evaluator.table)
      end
    end

    trait :for_user do
      transient do
        user nil
      end

      after(:build) do |table_ranking, evaluator|
        table_ranking.play = FactoryGirl.create(:play, user: evaluator.user)
      end
    end
  end
end

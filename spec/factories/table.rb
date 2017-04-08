FactoryGirl.define do
  factory :table do
    tournament
    title { Faker::Lorem.sentence }
    status { :opened }
    number_of_players { Faker::Number.between(1, 5) }
    description { Faker::Lorem.sentence }
    points_for_winners { [Faker::Number.number(5), Faker::Number.number(3), Faker::Number.number(2)] }
    entry_coins_cost { 0 }
    multiplier_chips_cost { 0 }
    coins_for_winners { [] }

    after :build do |table|
      datetime = table.end_time.nil? ? Time.now : (table.end_time - 3.hours)
      table.matches = Faker::Number.between(2, 5).times.collect { FactoryGirl.create(:match, tournament: table.tournament, datetime: datetime) } if table.matches.empty?
      table.start_time = datetime
      table.end_time = datetime + 3.hours
    end

    trait :with_table_rules do
      after :create do |table|
        TableRules.create!(table: table)
      end
    end

    trait :private do
      after :create do |table|
        table.update_attributes!(group: FactoryGirl.create(:group))
      end
    end

    trait :opened do
      transient do
        status nil
      end

      after :build do |table|
        table.status = :opened
      end
    end

    trait :closed do
      transient do
        status nil
      end

      after :build do |table|
        table.status = :closed
      end
    end

    trait :being_closed do
      transient do
        status nil
      end

      after :build do |table|
        table.status = :being_closed
      end
    end
  end
end

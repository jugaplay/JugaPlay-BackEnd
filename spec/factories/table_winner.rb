FactoryGirl.define do
  factory :table_winner do
    user
    table
    position { TableWinner.last.nil? ? 1 : (TableWinner.last.position + 1) }
  end
end

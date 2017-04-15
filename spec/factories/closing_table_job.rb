FactoryGirl.define do
  factory :closing_table_job do
    table
    status { :pending }
    priority { ClosingTableJob.last.nil? ? 1 : (ClosingTableJob.last.priority + 1) }
  end
end

FactoryGirl.define do
  factory :closing_table_job do
    table
    status { :pending }
    failures { 0 }
    priority { ClosingTableJob.last.nil? ? 1 : (ClosingTableJob.last.priority + 1) }
  end
end

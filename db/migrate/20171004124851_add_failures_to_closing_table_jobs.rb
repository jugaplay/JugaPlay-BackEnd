class AddFailuresToClosingTableJobs < ActiveRecord::Migration
  def change
    add_column :closing_table_jobs, :failures, :integer, default: 0, null: false
    ClosingTableJob.failed.each do |closing_table_job|
      closing_table_job.update_attributes!(failures: 3)
    end
  end
end

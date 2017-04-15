class BulkClosingTableJob
  def call
    ClosingTableJob.pendings.ordered.find_each do |closing_table_job|
      close_table(closing_table_job)
    end
  end

  private

  def close_table(closing_table_job)
    table = closing_table_job.table
    TableCloser.new(table).call
    ResultsMailer.for_table(table)
    closing_table_job.update_attributes!(stopped_at: DateTime.now, status: :finished_successfully)
  rescue Exception => error
    closing_table_job.update_attributes!(stopped_at: DateTime.now, status: :failed, error_message: error.message)
  end
end

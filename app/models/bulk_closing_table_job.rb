class BulkClosingTableJob
  def call
    ClosingTableJob.pending_or_retryable.ordered.find_each do |closing_table_job|
      close_table(closing_table_job)
      send_results_by_email(closing_table_job.table)
    end
  end

  private

  def close_table(closing_table_job)
    table = closing_table_job.table
    TableCloser.new(table).call
    closing_table_job.update_attributes!(stopped_at: DateTime.now, status: :finished_successfully)
  rescue Exception => error
    failures = closing_table_job.failures + 1
    closing_table_job.update_attributes!(stopped_at: DateTime.now, status: :failed, failures: failures, error_message: error.message)
  end

  def send_results_by_email(table)
    ResultsMailer.for_table(table)
  end
end

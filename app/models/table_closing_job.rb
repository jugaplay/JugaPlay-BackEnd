class TableClosingJob < ActiveJob::Base

  def perform(table_id)
    table = Table.find(table_id)
    TableCloser.new(table).call
    ResultsMailer.for_table(table)
  end

  def error(job)
    reopen_table(job)
  end

  def failure(job)
    reopen_table(job)
  end

  private

  def reopen_table(job)
    table = Table.find(job.arguments[0])
    table.open!
    table.save!
  end
end

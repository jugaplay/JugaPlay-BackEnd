class TableClosingJob < ActiveJob::Base

  def perform(table_id)
    table = Table.find(table_id)
    TableCloser.new(table).call
    ResultsMailer.for_table(table)
  end
end

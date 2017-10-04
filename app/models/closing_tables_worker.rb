class ClosingTablesWorker
  def self.for(table)
    new [table]
  end

  def self.for_all_tables_to_be_closed
    new Table.can_be_closed
  end

  def initialize(tables)
    @errors = []
    @tables = tables
    @validator = TableCloserValidator.new
    @last_job_priority = ClosingTableJob.last_job_priority
  end

  def call
    tables.each { |table| enqueue_job_for(table) }
    errors
  end

  private
  attr_reader :errors, :tables, :validator, :last_job_priority

  def enqueue_job_for(table)
    validator.validate_to_start_closing(table)
    ClosingTableJob.create!(table: table, priority: next_job_priority, status: :pending, failures: 0)
    table.start_closing!
  rescue ActiveRecord::RecordInvalid, MissingPlayerStats, TableIsClosed => error
    errors << { table: table, error_message: error.message }
  end

  def next_job_priority
    @last_job_priority += 1
  end
end

class TableIsNotBeingClosed < StandardError
  def self.for(table)
    new "The table #{table.title} should be being closed in order to process closing"
  end

  def initialize(message = 'The table is not being closed')
    super message
  end
end

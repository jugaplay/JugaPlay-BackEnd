class TableIsNotBeingClosed < StandardError
  def self.for(table)
    new "The table #{table.title} [#{table.id}] it's '#{table.status}' and should be 'being closed' in order to process closing"
  end

  def initialize(message = 'The table is not being closed')
    super message
  end
end

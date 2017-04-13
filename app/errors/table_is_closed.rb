class TableIsClosed < StandardError
  def self.for(table)
    new "The table #{table.title} [#{table.id}] is already closed" if table.closed?
    new "The table #{table.title} [#{table.id}] is being closed"
  end

  def initialize(message = 'The Table is already closed')
    super message
  end
end

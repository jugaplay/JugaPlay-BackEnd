class TableIsClosed < StandardError
  def initialize
    super 'The Table is alredy closed'
  end
end

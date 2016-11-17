class CoinsDispenser
  def self.for(table:, users:)
    validate_arguments(table, users)
    return PrivateTableCoinsDispenser.new(table, users) if table.private?
    PublicTableCoinsDispenser.new(table, users)
  end

  def initialize(table, users)
    @users, @table = users, table
  end
    
  def call
    fail 'subclass responsibility'
  end

  protected
  attr_reader :users, :table

  def self.validate_arguments(table, users)
    fail ArgumentError, 'Missing table' unless table.present?
    fail ArgumentError, 'Missing users' unless users.present?
  end
end

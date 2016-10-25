class UserDoesNotBelongToTableGroup < StandardError
  def initialize
    super 'User does not belong to table group'
  end
end

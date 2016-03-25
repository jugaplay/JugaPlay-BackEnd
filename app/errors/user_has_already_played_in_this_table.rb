class UserHasAlreadyPlayedInThisTable < StandardError
  def initialize
    super 'Given user has already played in this table'
  end
end
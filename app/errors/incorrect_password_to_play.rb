class IncorrectPasswordToPlay < StandardError
  def initialize
    super 'Incorrect password to play in this table'
  end
end
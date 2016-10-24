class UserHasNotLoggedInWithFacebook < StandardError
  def initialize
    super 'User has not logged in with facebook'
  end
end

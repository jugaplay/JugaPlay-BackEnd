class FacebookRequester
  def self.for user
    return RealFacebookRequester.new(user) if user.has_facebook_token?
    NullFacebookRequester.new(user)
  end

  def initialize user
    @user = user
    @fb_graph = FbGraph2::User.me(user.facebook_token)
  end

  def friends_list
    fail 'subclass responsibility'
  end

  protected
  attr_reader :fb_graph, :user
end

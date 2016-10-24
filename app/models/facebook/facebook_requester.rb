class FacebookRequester
  def initialize user
    raise_user_without_fb_login_error unless user.has_facebook_login?
    @user = user
    @fb_graph = FbGraph2::User.me(user.facebook_token)
  end

  def friends_list
    fb_graph.friends
  end

  private
  attr_reader :fb_graph, :user

  def raise_user_without_fb_login_error
    fail UserHasNotLoggedInWithFacebook
  end
end

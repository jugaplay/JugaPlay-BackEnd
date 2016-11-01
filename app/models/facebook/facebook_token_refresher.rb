class FacebookTokenRefresher
  def initialize user
    @user = user
    @fb_graph = FbGraph2::Auth.new(ENV['FB_APP_ID'], ENV['FB_APP_SECRET'])
  end

  def call(&on_fail_block)
    return unless user.has_facebook_token?
    fb_graph.fb_exchange_token = user.facebook_token
    token = fb_graph.access_token!(scope: 'email,user_friends', info_fields: 'email,first_name,last_name')
    user.update_attributes(facebook_token: token)
  rescue FbGraph2::Exception
    return on_fail_block.call(user)
  end

  private
  attr_reader :fb_graph, :user
end

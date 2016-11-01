class RealFacebookRequester < FacebookRequester
  def friends_list
    fb_graph.friends
  end
end

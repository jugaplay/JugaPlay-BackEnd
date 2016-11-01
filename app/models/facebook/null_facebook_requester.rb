class NullFacebookRequester < FacebookRequester
  def friends_list
    []
  end
end

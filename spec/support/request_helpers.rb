module RequestHelpers
  module Json
    def response_body
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  module Facebook
    FacebookUser = Struct.new(:id)

    def mock_facebook_token_refresh
      allow_any_instance_of(FacebookTokenRefresher).to receive(:call).and_return(true)
    end

    def mock_facebook_friend_list_with(users)
      facebook_users = users.map { |user| FacebookUser.new(user.facebook_id) }
      allow_any_instance_of(FacebookRequester).to receive(:friends_list).and_return(facebook_users)
    end
  end
end

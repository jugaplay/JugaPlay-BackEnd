module Request
  module JsonHelpers
    def response_body
      JSON.parse(response.body, symbolize_names: true)
    end
  end

  module FacebookHelpers
    def mock_facebook_token_refresh
      allow_any_instance_of(FacebookTokenManager).to receive(:call).and_return(true)
    end
  end
end

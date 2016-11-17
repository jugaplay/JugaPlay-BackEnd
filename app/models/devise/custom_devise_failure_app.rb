class CustomDeviseFailureApp < Devise::FailureApp
  def respond
    if request.format.eql? :json
      json_error_response
    else
      super
    end
  end

  def json_error_response
    self.status = 401
    self.content_type = 'application/json'
    self.response_body = { errors: ['You need to sign in or sign up before continuing.'] }.to_json
  end
end

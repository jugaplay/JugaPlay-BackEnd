require 'test_helper'

class Api::V1::MailerControllerTest < ActionController::TestCase
  test "should get send_request" do
    get :send_request
    assert_response :success
  end

end

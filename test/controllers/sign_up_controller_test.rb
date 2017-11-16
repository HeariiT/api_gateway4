require 'test_helper'

class SignUpControllerTest < ActionDispatch::IntegrationTest
  test "should get new_user" do
    get sign_up_new_user_url
    assert_response :success
  end

end

require 'test_helper'

class VolunteerControllerTest < ActionDispatch::IntegrationTest
  test "should get register" do
    get volunteer_register_url
    assert_response :success
  end

  test "should get confirm" do
    get volunteer_confirm_url
    assert_response :success
  end

end

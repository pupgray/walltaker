require "test_helper"

class WebFingerActorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get web_finger_actor_index_url
    assert_response :success
  end

  test "should get show" do
    get web_finger_actor_show_url
    assert_response :success
  end
end

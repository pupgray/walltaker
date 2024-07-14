require "test_helper"

class ActorControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get actor_show_url
    assert_response :success
  end
end

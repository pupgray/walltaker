require "test_helper"

class NewsRoomControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get news_room_index_url
    assert_response :success
  end
end

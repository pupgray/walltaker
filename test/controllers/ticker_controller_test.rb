require "test_helper"

class TickerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get ticker_index_url
    assert_response :success
  end
end

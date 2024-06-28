require "test_helper"

class LinkListsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get link_lists_index_url
    assert_response :success
  end

  test "should get show" do
    get link_lists_show_url
    assert_response :success
  end
end

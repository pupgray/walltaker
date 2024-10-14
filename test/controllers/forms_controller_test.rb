require "test_helper"

class FormsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @survey = forms(:one)
  end

  test "should get index" do
    get forms_url
    assert_response :success
  end

  test "should get new" do
    get new_form_url
    assert_response :success
  end

  test "should create form" do
    assert_difference("Form.count") do
      post forms_url, params: { survey: { description: @survey.description, public: @survey.public, title: @survey.title } }
    end

    assert_redirected_to form_url(Survey.last)
  end

  test "should show form" do
    get form_url(@survey)
    assert_response :success
  end

  test "should get edit" do
    get edit_form_url(@survey)
    assert_response :success
  end

  test "should update form" do
    patch form_url(@survey), params: { survey: { description: @survey.description, public: @survey.public, title: @survey.title } }
    assert_redirected_to form_url(@survey)
  end

  test "should destroy form" do
    assert_difference("Form.count", -1) do
      delete form_url(@survey)
    end

    assert_redirected_to forms_url
  end
end

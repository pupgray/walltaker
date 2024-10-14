require "application_system_test_case"

class FormElementsTest < ApplicationSystemTestCase
  setup do
    @form_element = form_elements(:one)
  end

  test "visiting the index" do
    visit form_elements_url
    assert_selector "h1", text: "Form elements"
  end

  test "should create form element" do
    visit form_elements_url
    click_on "New form element"

    click_on "Create Form element"

    assert_text "Form element was successfully created"
    click_on "Back"
  end

  test "should update Form element" do
    visit form_element_url(@form_element)
    click_on "Edit this form element", match: :first

    click_on "Update Form element"

    assert_text "Form element was successfully updated"
    click_on "Back"
  end

  test "should destroy Form element" do
    visit form_element_url(@form_element)
    click_on "Destroy this form element", match: :first

    assert_text "Form element was successfully destroyed"
  end
end

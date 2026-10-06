require "test_helper"

class AuthorsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "guests must log in to see authors and profiles" do
    get authors_path
    assert_redirected_to new_author_session_path
    get author_path(authors(:jane))
    assert_redirected_to new_author_session_path
  end

  test "logged in authors can see all authors and their books" do
    sign_in authors(:ursula)
    get authors_path
    assert_response :success
    assert_select "tbody tr", count: 2
    get author_path(authors(:jane))
    assert_response :success
    assert_select "h1", "Jane Austen"
    assert_select "tbody td", text: "Pride and Prejudice"
  end
end

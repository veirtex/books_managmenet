require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "an author can sign up with a name" do
    get new_author_registration_path
    assert_response :success
    assert_difference "Author.count", 1 do
      post author_registration_path, params: { author: {
        name: "New Author", email: "new@example.test", password: "password123"
      } }
    end
    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
    assert_select "a", text: "My profile (New Author)"
  end

  test "duplicate author names cannot sign up" do
    assert_no_difference "Author.count" do
      post author_registration_path, params: { author: {
        name: authors(:jane).name, email: "new@example.test", password: "password123"
      } }
    end
    assert_response :unprocessable_content
    assert_select "#error_explanation", /Name has already been taken/
  end

  test "login rejects wrong passwords and logout ends the session" do
    post author_session_path, params: { author: { email: authors(:jane).email, password: "wrong" } }
    assert_response :unprocessable_content
    get books_path
    assert_redirected_to new_author_session_path
    post author_session_path, params: { author: { email: authors(:jane).email, password: "password123" } }
    assert_redirected_to books_path
    follow_redirect!
    assert_response :success
    delete destroy_author_session_path
    assert_response :see_other
    get books_path
    assert_redirected_to new_author_session_path
  end
end

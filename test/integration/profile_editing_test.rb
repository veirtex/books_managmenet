require "test_helper"

class ProfileEditingTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @author = authors(:jane)
    @other = authors(:ursula)
  end

  test "editing requires login and the link appears only on your own profile" do
    get edit_author_registration_path
    assert_redirected_to new_author_session_path
    sign_in @author
    get author_path(@author)
    assert_select "a[href=?]", edit_author_registration_path, text: "Edit profile"
    get author_path(@other)
    assert_select "a[href=?]", edit_author_registration_path, count: 0
    get edit_author_registration_path
    assert_response :success
    assert_select "input[name='author[name]'][value='Jane Austen']"
  end

  test "updates your name and email while keeping a blank password unchanged" do
    sign_in @author
    put author_registration_path, params: { author: {
      id: @other.id, name: "Jane Updated", email: "updated@example.test",
      password: "", password_confirmation: "", current_password: "password123"
    } }
    assert_response :see_other
    assert_equal "Jane Updated", @author.reload.name
    assert_equal "updated@example.test", @author.email
    assert @author.valid_password?("password123")
    assert_equal "Ursula Le Guin", @other.reload.name
  end

  test "invalid password and duplicate name display errors without saving" do
    sign_in @author
    put author_registration_path, params: { author: { name: "Changed", current_password: "wrong" } }
    assert_response :unprocessable_content
    assert_equal "Jane Austen", @author.reload.name
    assert_select "#error_explanation", /Current password is invalid/

    put author_registration_path, params: { author: { name: @other.name, current_password: "password123" } }
    assert_response :unprocessable_content
    assert_equal "Jane Austen", @author.reload.name
    assert_select "#error_explanation", /Name has already been taken/
  end

  test "an author can change their password with the current password" do
    sign_in @author
    put author_registration_path, params: { author: {
      password: "newpassword123", password_confirmation: "newpassword123", current_password: "password123"
    } }
    assert_response :see_other
    assert @author.reload.valid_password?("newpassword123")
    assert_not @author.valid_password?("password123")
  end
end

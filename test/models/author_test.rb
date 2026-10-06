require "test_helper"

class AuthorTest < ActiveSupport::TestCase
  test "name and account fields are required" do
    author = Author.new
    assert_not author.valid?
    [ :name, :email, :password ].each { |field| assert author.errors[field].any? }
  end

  test "names must be unique" do
    author = Author.new(name: authors(:jane).name, email: "another@example.test", password: "password123")
    assert_not author.valid?
    assert_includes author.errors[:name], "has already been taken"
  end

  test "an author has their own books" do
    assert_equal [ books(:pride), books(:emma) ].sort_by(&:id), authors(:jane).books.order(:id).to_a
  end
end

require "test_helper"
require "csv"

class BooksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @book = books(:pride)
    @owner = authors(:jane)
    @other = authors(:ursula)
  end

  test "guests cannot read or change books" do
    [ books_path, book_path(@book), new_book_path, edit_book_path(@book) ].each do |path|
      get path
      assert_redirected_to new_author_session_path
    end
    get books_path(format: :csv)
    assert_response :unauthorized
    assert_no_difference "Book.count" do
      post books_path, params: { book: { title: "Guest book", published_at: Date.current } }
      assert_redirected_to new_author_session_path
      patch book_path(@book), params: { book: { title: "Guest change" } }
      assert_redirected_to new_author_session_path
      delete book_path(@book)
      assert_redirected_to new_author_session_path
    end
    assert_equal "Pride and Prejudice", @book.reload.title
  end

  test "signed in authors can view all books" do
    sign_in @other
    get books_path
    assert_response :success
    assert_select "tbody tr", count: 3
    get book_path(@book)
    assert_response :success
    assert_select "h1", @book.title
    assert_select "a[href=?]", edit_book_path(@book), count: 0
    assert_select "button", text: "Delete", count: 0
  end

  test "owners can create edit and delete their books without changing ownership" do
    sign_in @owner
    get new_book_path
    assert_response :success
    assert_difference "Book.count", 1 do
      post books_path, params: { book: { title: "New book", published_at: "2020-01-01", author_id: @other.id } }
    end
    book = Book.find_by!(title: "New book")
    assert_equal @owner, book.author
    assert_redirected_to book_path(book)
    get edit_book_path(book)
    assert_response :success
    patch book_path(book), params: { book: { title: "Updated book", author_id: @other.id } }
    assert_redirected_to book_path(book)
    assert_equal "Updated book", book.reload.title
    assert_equal @owner, book.author
    assert_difference "Book.count", -1 do
      delete book_path(book)
    end
    assert_redirected_to books_path
  end

  test "another author cannot edit update or delete a book" do
    sign_in @other
    get book_path(@book)
    get edit_book_path(@book)
    assert_response :not_found
    patch book_path(@book), params: { book: { title: "Changed" } }
    assert_response :not_found
    assert_equal "Pride and Prejudice", @book.reload.title
    assert_no_difference "Book.count" do
      delete book_path(@book)
    end
    assert_response :not_found
  end

  test "invalid creates and updates show errors without saving" do
    sign_in @owner
    assert_no_difference "Book.count" do
      post books_path, params: { book: { title: "", published_at: Date.tomorrow } }
    end
    assert_response :unprocessable_content
    assert_select "[role=alert]", /must be today or earlier/
    patch book_path(@book), params: { book: { published_at: Date.tomorrow } }
    assert_response :unprocessable_content
    assert_equal Date.new(1813, 1, 28), @book.reload.published_at
    patch book_path(@book), params: { book: { title: books(:earthsea).title } }
    assert_response :unprocessable_content
    assert_select "[role=alert]", /has already been taken/
    assert_equal "Pride and Prejudice", @book.reload.title
  end

  test "CSV exports the filtered books with the required columns" do
    sign_in @owner
    filters = { with_name: "pride", released_on: "1813-01-28", with_author_name: "austen" }
    get books_path, params: { filterrific: filters }
    assert_select "a", text: "Download CSV"
    get books_path(format: :csv), params: { filterrific: filters }
    assert_response :success
    assert_equal "text/csv", response.media_type
    assert_match "attachment", response.headers["Content-Disposition"]
    rows = CSV.parse(response.body, headers: true)
    assert_equal [ "Book name", "Release date", "Author name" ], rows.headers
    assert_equal [ [ "Pride and Prejudice", "1813-01-28", "Jane Austen" ] ], rows.map(&:fields)
    get books_path(format: :csv), params: { filterrific: { with_name: "missing" } }
    assert_empty CSV.parse(response.body, headers: true)
  end

  test "CSV preserves quotes commas and newlines" do
    sign_in @owner
    title = "A title, with \"quotes\"\nand a newline"
    @book.update!(title: title)
    get books_path(format: :csv)
    assert_includes CSV.parse(response.body, headers: true).map { |row| row["Book name"] }, title
  end
end

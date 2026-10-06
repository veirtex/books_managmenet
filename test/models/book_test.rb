require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "name release date and author are required" do
    book = Book.new
    assert_not book.valid?
    [ :title, :published_at, :author ].each { |field| assert book.errors[field].any? }
  end

  test "book names must be unique within an author" do
    book = authors(:jane).books.new(title: books(:pride).title, published_at: Date.current)
    assert_not book.valid?
    assert_includes book.errors[:title], "has already been taken"
    assert_raises ActiveRecord::RecordNotUnique do
      Book.transaction(requires_new: true) { book.save!(validate: false) }
    end
  end

  test "different authors cannot use the same book name" do
    book = authors(:ursula).books.new(title: books(:pride).title, published_at: Date.current)
    assert_not book.valid?
    assert_includes book.errors[:title], "has already been taken"
    assert_raises ActiveRecord::RecordNotUnique do
      Book.transaction(requires_new: true) { book.save!(validate: false) }
    end
  end

  test "release dates allow today and the past but not future or invalid dates" do
    book = books(:pride)
    [ Date.current, Date.yesterday ].each do |date|
      book.published_at = date
      assert book.valid?
    end
    book.published_at = Date.tomorrow
    assert_not book.valid?
    assert_includes book.errors[:published_at], "must be today or earlier"
    book.published_at = "not-a-date"
    assert_not book.valid?
  end
end

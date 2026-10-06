require "test_helper"

class IndexFiltersTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    sign_in authors(:jane)
  end

  test "authors filter by partial name and reset without remembered filters" do
    get authors_path, params: { filterrific: { with_name: "AUS" } }
    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody td", text: "Jane Austen"
    assert_select "input[name='filterrific[with_name]'][value='AUS']"

    get authors_path
    assert_select "tbody tr", count: 2
  end

  test "each book filter works independently" do
    { with_name: "EARTH", released_on: "1968-11-01", with_author_name: "urs" }.each do |key, value|
      get books_path, params: { filterrific: { key => value } }
      assert_response :success
      assert_select "tbody tr", count: 1
      assert_select "tbody td", text: "A Wizard of Earthsea"
    end
  end

  test "book filters combine and reset clears them" do
    filters = { with_name: "pride", released_on: "1813-01-28", with_author_name: "AUSTEN" }
    get books_path, params: { filterrific: filters }
    assert_response :success
    assert_select "tbody tr", count: 1
    assert_select "tbody td", text: "Pride and Prejudice"

    get books_path, params: { filterrific: filters.merge(with_author_name: "ursula") }
    assert_select "tbody tr", count: 0

    get books_path
    assert_select "tbody tr", count: 3
    get books_path, params: { filterrific: { with_name: "", released_on: "", with_author_name: "" } }
    assert_select "tbody tr", count: 3
  end

  test "invalid dates and unmatched names return no rows" do
    [ "not-a-date", "2026-99-99" ].each do |date|
      get books_path, params: { filterrific: { released_on: date } }
      assert_response :success
      assert_select "tbody tr", count: 0
    end
    get authors_path, params: { filterrific: { with_name: "Nobody" } }
    assert_select "tbody tr", count: 0
  end

  test "name filters treat SQL wildcards as literal text" do
    get authors_path, params: { filterrific: { with_name: "%" } }
    assert_select "tbody tr", count: 0
    get books_path, params: { filterrific: { with_name: "_" } }
    assert_select "tbody tr", count: 0
    get books_path, params: { filterrific: { with_author_name: "%" } }
    assert_select "tbody tr", count: 0
  end
end

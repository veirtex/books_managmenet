require "csv"

class BooksController < ApplicationController
  before_action :set_owned_book, only: [ :edit, :update, :destroy ]

  def index
    filters = params.fetch(:filterrific, ActionController::Parameters.new).permit(:with_name, :released_on, :with_author_name)
    @filterrific = initialize_filterrific(Book, filters, persistence_id: false) or return
    @books = @filterrific.find.includes(:author)

    respond_to do |format|
      format.html
      format.csv do
        csv = CSV.generate(headers: [ "Book name", "Release date", "Author name" ], write_headers: true) do |rows|
          @books.each do |book|
            rows << [ book.title, book.published_at.iso8601, book.author.name ]
          end
        end
        send_data csv, filename: "books.csv", type: "text/csv"
      end
    end
  end

  def show
    @book = Book.find(params[:id])
  end

  def new
    @book = current_author.books.new
  end

  def create
    @book = current_author.books.new(book_params)
    if @book.save
      redirect_to book_path(@book), notice: "Book created.", status: :see_other
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to book_path(@book), notice: "Book updated.", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @book.destroy!
    redirect_to books_path, notice: "Book deleted.", status: :see_other
  end

  private

  def set_owned_book
    @book = current_author.books.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :published_at)
  end
end

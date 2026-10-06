class AuthorsController < ApplicationController
  def index
    filters = params.fetch(:filterrific, ActionController::Parameters.new).permit(:with_name)
    @filterrific = initialize_filterrific(Author, filters, persistence_id: false) or return
    @authors = @filterrific.find
  end

  def show
    @author = Author.find(params[:id])
  end
end

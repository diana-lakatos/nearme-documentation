class SearchController < ApplicationController

  def index
    @query = params[:q]
    @results = Workplace.search_with_location(@query)
  end

end

class SearchController < ApplicationController

  def index
    @query = params[:q]
    @workplaces, @location = Workplace.search_with_location(@query)
  end

end

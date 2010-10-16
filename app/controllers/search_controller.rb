class SearchController < ApplicationController

  def index
    @query = params[:q]
    @workplaces, @location = Workplace.search_by_location(@query)
  end

end

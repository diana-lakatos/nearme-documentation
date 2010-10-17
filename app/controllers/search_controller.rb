class SearchController < ApplicationController

  def index
    @query = params[:q]
    @workplaces, @location = Workplace.search_by_location(@query)
    @workplaces = @workplaces.paginate :page => params[:page]
  end

end

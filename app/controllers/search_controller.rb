class SearchController < ApplicationController

  def index
    @query = params[:q]
  end

  def query
    @search = params[:search]
    @workplaces = Workplace.search_by_location(@search)
    @workplaces = @workplaces.paginate :page => params[:page]
    render :template => "search/results.html", :layout => false
  end

end

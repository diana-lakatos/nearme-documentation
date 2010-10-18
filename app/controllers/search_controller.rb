class SearchController < ApplicationController

  def index
    @query = params[:q]
  end

  def query
    page = params.delete(:page)
    @search = params
    @workplaces = Workplace.search_by_location(@search, :include => :photos, :page => page, :per_page => 20)
    render :template => "search/results.html", :layout => false
  end

end

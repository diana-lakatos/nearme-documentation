class SearchController < ApplicationController

  def index
    @query = params[:q]
  end

  def query
    page = params.delete(:page)
    @search = { :query => params[:q], :lat => params[:lat], :lng => params[:lng] }
    if params[:nx]
      @search[:northeast] = { :lat => params[:nx] }
      @search[:northeast][:lng] = params[:ny] if params[:ny]
    end
    if params[:sx]
      @search[:southwest] = { :lat => params[:sx] }
      @search[:southwest][:lng] = params[:sy] if params[:sy]
    end
    @workplaces = Workplace.search_by_location(@search, :include => :photos, :page => page, :per_page => 20)
    render :template => "search/results.html", :layout => false
  end

end

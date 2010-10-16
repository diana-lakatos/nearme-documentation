class SearchController < ApplicationController

  def index
    @query = params[:q]
    @results = MagicSearch.search(@query)
  end

end

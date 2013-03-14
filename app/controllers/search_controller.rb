require "will_paginate/array"
class SearchController < ApplicationController
  def index
    @search = Listing::Search::Params::Web.new(params)
    @listings = Listing.find_by_search_params(@search)
    @query = @search.location_string
    
    if request.xhr?
      render :partial => "search/listings", :layout => false
    end
  end
end

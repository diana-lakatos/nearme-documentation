require "will_paginate/array"
class SearchController < ApplicationController
  def index
    @search = Listing::Search::Params::Web.new(params)

    @listings = Listing.find_by_search_params(@search)
    @query = @search.location_string

    SearchQuery.create(:query => @search.location_string, :agent => request.env['HTTP_USER_AGENT'])
    if request.xhr?
      render :partial => "search/listings", :layout => false
    else
      render
    end
  end
end

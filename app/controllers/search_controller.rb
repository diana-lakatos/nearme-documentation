require "will_paginate/array"
class SearchController < ApplicationController

  def index

    current_params = params
    if params[:q]
      session[:search_query] = current_params
    else
      current_params = session[:search_query]
    end
    @search = Listing::Search::Params::Web.new(current_params)

    @listings = Listing.find_by_search_params(@search).reject { |l| l.location.nil? } # tmp hax
    @query = @search.location_string

    SearchQuery.create(:query => @search.location_string, :agent => request.env['HTTP_USER_AGENT'])

    if request.xhr?
      render :partial => "search/listings", :layout => false
    else
      render
    end
  end

  private

end

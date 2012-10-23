require "will_paginate/array"
class SearchController < ApplicationController

  def index
    @search = Listing::SearchParams.new(params)

    @listings = Listing.find_by_search_params(@search.parsed_params).reject { |l| l.location.nil? } # tmp hax
    @listings = @listings.paginate(:page => params[:page], :per_page => 20)

    SearchQuery.create(:query => @search.location_string, :agent => request.env['HTTP_USER_AGENT'])

    if request.xhr?
      render :partial => "search/listings", :layout => false
    else
      render
    end
  end

  private

end

require "will_paginate/array"
class SearchController < ApplicationController
  
  layout Proc.new { |c| if c.request.xhr? then false else 'application' end }
  helper_method :search, :query, :listings, :result_view
  
  SEARCH_RESULT_VIEWS = %w(list map)
  
  def index
    render "search/#{result_view}"
  end
  
  private
  
  def search
    @search ||= Listing::Search::Params::Web.new(params)
  end
  
  def query
    @query ||= search.location_string
  end
  
  def locations
    # @locations ||= Location.find_by_search_params(search)
  end
  
  def listings
    @listings ||=  get_listings
  end

  def get_listings
    collection = Listing.find_by_search_params(search)
    params[:page] ||= 1
    if result_view == 'list'
      collection = WillPaginate::Collection.create(params[:page], 20, collection.count) do |pager|
        pager.replace(collection[pager.offset, pager.per_page].to_a)
      end
    end
    collection
  end
  
  def result_view
    requested_view = params.fetch(:v, 'list').downcase
    @result_view ||= if SEARCH_RESULT_VIEWS.include?(requested_view)
      requested_view
    else
      'list'
    end
  end
  
end

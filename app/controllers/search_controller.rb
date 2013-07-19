require "will_paginate/array"
class SearchController < ApplicationController

  helper_method :search, :query, :listings, :result_view

  SEARCH_RESULT_VIEWS = %w(list map)

  def index
    render "search/#{result_view}"
    event_tracker.conducted_a_search(search, {search_query: query, result_view: result_view, result_count: result_count })
  end

  private

  def search
    @search ||= Listing::Search::Params::Web.new(params)
  end

  def query
    @query ||= search.query
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

  def result_count
    if result_view == 'list'
      @listings.total_entries
    else
     @listings.size
    end
  end

end

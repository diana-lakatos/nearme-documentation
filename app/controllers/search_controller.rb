require "will_paginate/array"
class SearchController < ApplicationController

  helper_method :search, :query, :listings, :result_view, :search_notification

  SEARCH_RESULT_VIEWS = %w(list map)

  def index
    @located = (params[:lat].present? and params[:lng].present?)
    render "search/#{result_view}"
    if should_log_conducted_search?
      event_tracker.conducted_a_search(search, { search_query: query, result_view: result_view, result_count: result_count })
    end
    remember_search_query
  end

  def show
    @listings = Listing.find(params[:id].split(','))
    render partial: "search/#{result_view}/listing", collection: listings, as: :listing
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
    collection = Listing.find_by_search_params(search, scoped_locations)
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

  def should_log_conducted_search?
    first_result_page? && ignore_search_event_flag_false? && !repeated_search? && params[:q]
  end

  def first_result_page?
    !params[:page] || params[:page].to_i==1
  end

  def ignore_search_event_flag_false?
    params[:ignore_search_event].nil? || params[:ignore_search_event].to_i.zero?
  end

  def remember_search_query
    if params[:q]
      cookies[:last_search_query] = {
        :value => params[:q],
        :expires => (Time.zone.now + 1.hour),
      }
    end
  end

  def repeated_search?
    params[:q] && params[:q] == cookies[:last_search_query]
  end

  def search_notification
    @search_notification ||= SearchNotification.new(query: params[:q], latitude: params[:lat], longitude: params[:lng])
  end
end

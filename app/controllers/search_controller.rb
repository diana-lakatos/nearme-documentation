require "will_paginate/array"
class SearchController < ApplicationController

  helper_method :search, :query, :listings, :result_view, :search_notification

  SEARCH_RESULT_VIEWS = %w(list map)

  def index
    @located = (params[:lat].present? and params[:lng].present?)
    render "search/#{result_view}"
    if should_log_conducted_search?
      event_tracker.conducted_a_search(search, { search_query: query, result_view: result_view, result_count: result_count}.merge(filters))
    end

    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]

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

  def filters
    search_filters = {}
    search_filters[:listing_type_filter] = params[:listing_types_ids].map { |lt| ListingType.find(lt).name } if params[:listing_types_ids]
    search_filters[:location_type_filter] = params[:location_types_ids].map { |lt| LocationType.find(lt).name } if params[:location_types_ids]
    search_filters[:industry_filter] = params[:industries_ids].map { |i| Industry.find(i).name } if params[:industries_ids]
    search_filters
  end

  def listings
    @listings ||=  get_listings
  end

  def get_listings
    params_object = Listing::Search::Params::Web.new(params)
    search_params = params.merge({:midpoint => params_object.midpoint, :radius => params_object.radius, :available_dates => params_object.available_dates})
    collection = Listing::SearchFetcher.new(search_scope, search_params).listings
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
        :value => search_query_values,
        :expires => (Time.zone.now + 1.hour),
      }
    end
  end

  def search_query_values
    { 
      :q => params[:q],
      :listing_types_ids => params[:listing_types_ids],
      :location_types_ids => params[:location_types_ids],
      :industries_ids => params[:industries_ids]
    }

  end

  def repeated_search?
    params[:q] && search_query_values.to_s == cookies[:last_search_query].try(:to_s)
  end

  def search_notification
    @search_notification ||= SearchNotification.new(query: params[:q], latitude: params[:lat], longitude: params[:lng])
  end
end

require "will_paginate/array"
class SearchController < ApplicationController
  extend ::NewRelic::Agent::MethodTracer

  helper_method :search, :query, :listings, :locations, :result_view, :search_notification, :result_count, :current_page_offset
  before_filter :set_options_for_filters

  SEARCH_RESULT_VIEWS = %w(list map mixed)

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

    if result_view.mixed?
      search_filters[:listing_type_filter] = search.listing_types_ids.map(&:name) if search.listing_types_ids && !search.listing_types_ids.empty?
      search_filters[:location_type_filter] = search.location_types_ids.map(&:name) if search.location_types_ids && !search.location_types_ids.empty?
      search_filters[:listing_pricing_filter] = search.lgpricing_filters if not search.lgpricing_filters.empty?
    else
      search_filters[:listing_type_filter] = params[:listing_types_ids].map { |lt| ListingType.find(lt).name } if params[:listing_types_ids]
      search_filters[:location_type_filter] = params[:location_types_ids].map { |lt| LocationType.find(lt).name } if params[:location_types_ids]
      search_filters[:industry_filter] = params[:industries_ids].map { |i| Industry.find(i).name } if params[:industries_ids]
    end

    search_filters
  end

  def listings
    @listings ||= get_listings
  end

  def locations
    @locations ||= get_locations
  end

  def fetcher
    @fetcher ||=
      begin
        @search_params = params.merge({
          :midpoint => search.midpoint,
          :radius => search.radius,
          :available_dates => search.available_dates,
          :query => search.query,
          :location_types_ids => search.location_types_ids,
          :listing_types_ids => search.listing_types_ids,
          :listing_pricing => search.lgpricing.blank? ? [] : search.lgpricing_filters,
          :sort => search.sort
        })

        Listing::SearchFetcher.new(search_scope, @search_params)
      end
  end

  def get_locations
    params[:page] ||= 1
    self.class.trace_execution_scoped(['Custom/get_locations/fetch_locations']) do
      @collection = fetcher.locations
    end

    if result_view.list? || result_view.mixed?
      self.class.trace_execution_scoped(['Custom/get_locations/paginate_locations']) do
        @collection = WillPaginate::Collection.create(params[:page], per_page, @collection.count) do |pager|
          pager.replace(@collection[pager.offset, pager.per_page].to_a)
        end
      end
    end

    @listings = Listing.searchable.where(location_id: @collection.map(&:id))

    @collection
  end

  def get_listings
    params[:page] ||= 1
    self.class.trace_execution_scoped(['Custom/get_listings/fetch_listings']) do
      @collection = fetcher.listings
    end

    if result_view.list? || result_view.mixed?
      self.class.trace_execution_scoped(['Custom/get_listings/paginate_listings']) do
        @collection = WillPaginate::Collection.create(params[:page], per_page, @collection.count) do |pager|
          pager.replace(@collection[pager.offset, pager.per_page].to_a)
        end
      end
    end
    @collection
  end

  def result_view
    requested_view = params.fetch(:v, 'mixed').downcase
    @result_view ||= (if SEARCH_RESULT_VIEWS.include?(requested_view)
                       requested_view
                     else
                       'mixed'
                     end).inquiry
  end

  def result_count
    if result_view.list?
      @listings.total_entries
    elsif result_view.mixed?
      @locations.total_entries
    else
      @listings.size
    end
  end

  def current_page_offset
    @current_page_offset ||= ((params[:page] || 1).to_i - 1) * per_page
  end

  def should_log_conducted_search?
    first_result_page? && ignore_search_event_flag_false? && !repeated_search? && params[:loc]
  end

  def first_result_page?
    !params[:page] || params[:page].to_i==1
  end

  def ignore_search_event_flag_false?
    params[:ignore_search_event].nil? || params[:ignore_search_event].to_i.zero?
  end

  def remember_search_query
    if params[:loc]
      cookies[:last_search_query] = {
        :value => search_query_values,
        :expires => (Time.zone.now + 1.hour),
      }
    end
  end

  def search_query_values
    { 
      :loc => params[:loc],
      :listing_types_ids => search.listing_types_ids,
      :location_types_ids => search.location_types_ids,
      :industries_ids => params[:industries_ids],
      :listing_pricing => search.lgpricing
    }

  end

  def repeated_search?
    params[:loc] && search_query_values.to_s == cookies[:last_search_query].try(:to_s)
  end

  def search_notification
    @search_notification ||= SearchNotification.new(query: params[:loc], latitude: params[:lat], longitude: params[:lng])
  end

  def set_options_for_filters
    @filterable_location_types = platform_context.instance.location_types
    @filterable_listing_types = platform_context.instance.listing_types
    @filterable_pricing = [['hourly', 'hourly'], ['daily', 'daily'], ['weekly', 'weekly'], ['monthly', 'monthly']]
    @filterable_industries = Industry.with_listings.all if platform_context.instance.is_desksnearme? and !result_view.mixed?
  end

  def per_page
    result_view.mixed? ? 18 : 20
  end

end

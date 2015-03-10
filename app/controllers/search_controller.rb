require "will_paginate/array"
class SearchController < ApplicationController
  before_filter :theme_name

  before_filter :find_transactable_type

  helper_method :searcher, :result_view, :current_page_offset, :per_page, :first_result_page?

  def index
    if @transactable_type.buyable?
      @searcher = InstanceType::Searcher::ProductsSearcher.new(@transactable_type, params)
    elsif platform_context.instance.searcher_type == 'fulltext'
      @searcher = InstanceType::Searcher::FullTextSearcher::Listing.new(@transactable_type, params)
    elsif result_view == 'mixed'
      @searcher = InstanceType::Searcher::GeolocationSearcher::Location.new(@transactable_type, params)
    else
      @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(@transactable_type, params)
    end

    @searcher.paginate_results(params[:page], per_page) unless result_view == 'map'
    event_tracker.conducted_a_search(@searcher.search, @searcher.to_event_params.merge(result_view: result_view)) if should_log_conducted_search?
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
    remember_search_query
    render "search/#{result_view}"
  end

  private

  def result_view
    @result_view = params[:v].presence || (@transactable_type.buyable? ? "products" : platform_context.instance.default_search_view)
    @result_view.in?( %w( list map mixed listing_mixed products ) ) ? @result_view : 'mixed'
  end

  def should_log_conducted_search?
    first_result_page? && ignore_search_event_flag_false? && searcher.should_log_conducted_search? && !repeated_search?
  end

  def remember_search_query
    cookies[:last_search_query] = {
      :value => searcher.search_query_values,
      :expires => (Time.zone.now + 1.hour),
    }
  end

  def searcher
    @searcher
  end

  def repeated_search?
    searcher.repeated_search?(cookies[:last_search_query])
  end

  def current_page_offset
    @current_page_offset ||= ((params[:page] || 1).to_i - 1) * per_page
  end

  def first_result_page?
    !params[:page] || params[:page].to_i==1
  end

  def per_page
    (params[:per_page] || 20).to_i
  end

  def ignore_search_event_flag_false?
    params[:ignore_search_event].nil? || params[:ignore_search_event].to_i.zero?
  end

  def theme_name
    @theme_name = 'buy-sell-theme' if params[:buyable] == "true"
  end

  def find_transactable_type
    if params[:buyable] == "true"
      @transactable_type = params[:transactable_type_id].present? ? Spree::ProductType.find(params[:transactable_type_id]) : Spree::ProductType.first
    else
      @transactable_type = params[:transactable_type_id].present? ? TransactableType.find(params[:transactable_type_id]) : TransactableType.first
    end
    params[:transactable_type_id] ||= @transactable_type.id
  end

end


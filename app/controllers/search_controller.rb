require "will_paginate/array"
class SearchController < ApplicationController

  include SearchHelper
  include SearcherHelper

  before_filter :theme_name
  before_filter :find_transactable_type

  helper_method :searcher, :result_view, :current_page_offset, :per_page, :first_result_page?

  def index
    @searcher = instantiate_searcher(@transactable_type, params)
    @searcher.paginate_results(params[:page], per_page)
    event_tracker.conducted_a_search(@searcher.search, @searcher.to_event_params.merge(result_view: result_view)) if should_log_conducted_search?
    event_tracker.track_event_within_email(current_user, request) if params[:track_email_event]
    remember_search_query
    render "search/#{result_view}"
  end

  def categories
    @categories = Category.where(id: params[:category_ids].to_s.split(','))
    @categories_html = ''
    @categories.each do |category|
      next if category.children.blank?
      @categories_html << render_to_string(
        partial: 'search/mixed/filter',
        locals: {
          header_name: category.translated_name,
          selected_values: params[:category_ids].split(',') || [],
          input_name: 'category_ids[]',
          options: category.children.inject([]) { |options, c| options << [c.id, c.name]}
        }
      )
    end
    render text: @categories_html
  end

  private

  def should_log_conducted_search?
    first_result_page? && ignore_search_event_flag_false? && searcher.should_log_conducted_search? && !repeated_search?
  end

  def remember_search_query
    cookies[:last_search_query] = {
      value: searcher.search_query_values,
      expires: (Time.zone.now + 1.hour),
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

end


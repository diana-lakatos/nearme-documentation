require "will_paginate/array"
class SearchController < ApplicationController

  include SearchHelper

  before_filter :theme_name
  before_filter :find_transactable_type
  before_filter :set_taxonomies
  before_filter :set_taxon_breadcrumb

  helper_method :searcher, :result_view, :current_page_offset, :per_page, :first_result_page?

  def index
    if @transactable_type.buyable?
      @searcher = InstanceType::Searcher::ProductsSearcher.new(@transactable_type, params)
    elsif result_view == 'mixed'
      @searcher = InstanceType::Searcher::GeolocationSearcher::Location.new(@transactable_type, params)
    else
      @searcher = InstanceType::Searcher::GeolocationSearcher::Listing.new(@transactable_type, params)
    end

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
          header_name: 'Category',
          header_object: category,
          selected_values: params[:category_ids].split(',') || [],
          input_name: 'category_ids[]',
          options: category.children.inject([]) { |options, c| options << [c.id, c.name]}
        }
      )
    end
    render text: @categories_html
  end

  private

  def result_view
    @result_view = params[:v].presence || (@transactable_type.buyable? ? platform_context.instance.default_products_search_view : platform_context.instance.default_search_view)
    @result_view = @result_view.in?(Instance::SEARCH_SERVICE_VIEWS + Instance::SEARCH_PRODUCTS_VIEWS) ? @result_view : 'mixed'
    (@result_view.in?(Instance::SEARCH_PRODUCTS_VIEWS) && !@transactable_type.buyable?) ? 'mixed' : @result_view
  end

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

  def find_transactable_type
    if params[:buyable] == "true"
      @transactable_type = params[:transactable_type_id].present? ? Spree::ProductType.find(params[:transactable_type_id]) : Spree::ProductType.first
    else
      @transactable_type = params[:transactable_type_id].present? ? TransactableType.find(params[:transactable_type_id]) : TransactableType.first
    end
    params[:transactable_type_id] ||= @transactable_type.id
  end

  def set_taxonomies
    @taxon = Spree::Taxon.where.not(parent_id: nil).find_by_permalink(params[:taxon]) if params[:taxon]
    if @taxon.present?
      @taxons = [@taxon.children.present? ? @taxon : @taxon.parent]
    else
      @taxons = Spree::Taxonomy.includes(root: :children).map(&:root)
      params[:taxon] = nil if @taxon.blank?
    end
  end

  def set_taxon_breadcrumb
    if @taxon
      @breadcrumbs = []
      add_taxon_breadcrumbs (@taxon)
      @breadcrumbs.reverse.each do |breadcrumb|
        add_crumb breadcrumb[:name], breadcrumb[:path]
      end
    end
  end

  def add_taxon_breadcrumbs(taxon)
    @breadcrumbs << { name: taxon.name, path: taxon_custom_path(taxon) }
    add_taxon_breadcrumbs(taxon.parent) if taxon.parent
  end
end


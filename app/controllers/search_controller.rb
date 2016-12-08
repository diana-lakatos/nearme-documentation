require 'will_paginate/array'
class SearchController < ApplicationController
  include SearchHelper
  include SearcherHelper

  before_action :ensure_valid_params
  before_action :find_transactable_type
  before_action :assign_transactable_type_id_to_lookup_context
  before_action :store_search

  before_action :parse_uot_search_params, if:
    -> { PlatformContext.current.instance.id.eql?(195) || params[:search_type] == 'people' }
  before_action :parse_community_search_params, if:
    -> { PlatformContext.current.instance.is_community? }

  helper_method :searcher, :result_view, :current_page_offset, :per_page, :first_result_page?

  def index
    search_params = params.merge(per_page: per_page).reverse_merge(sort: @transactable_type.default_sort_by)
    @searcher = InstanceType::SearcherFactory.new(@transactable_type, search_params, result_view, current_user).get_searcher
    @searcher.paginate_results([(params[:page].presence || 1).to_i, 1].max, per_page)
    remember_search_query

    render "search/#{result_view}", formats: [:html]
  end

  def categories
    category_ids = params[:category_ids].to_s.split(',').map(&:to_i)
    category_root_ids = Category.roots.map(&:id)
    @categories = Category.where(id: category_ids).order('position ASC, id ASC').to_a
    @categories_html = ''
    @categories.reject! { |c| c.parent.present? && !category_root_ids.include?(c.parent.id) && !category_ids.include?(c.parent.id) }
    @categories.each do |category|
      next if category.children.blank?
      @categories_html << render_to_string(
        partial: 'search/mixed/filter',
        formats: [:html],
        locals: {
          category_id: category.id,
          header_name: category.translated_name,
          selected_values: params[:category_ids].split(',') || [],
          input_name: 'category_ids[]',
          options: category.children.inject([]) { |options, c| options << [c.id, c.name] }
        }
      )
    end
    render text: @categories_html
  end

  def ensure_valid_params
    redirect_to :back unless is_valid_single_param?(params[:transactable_type_id])
  rescue
    # No referrer was present
    redirect_to root_path
  end

  private
  def remember_search_query
    cookies[:last_search_query] = {
      value: searcher.search_query_values,
      expires: (Time.zone.now + 1.hour)
    }
  end

  attr_reader :searcher

  def repeated_search?
    searcher.repeated_search?(cookies[:last_search_query])
  end

  def current_page_offset
    @current_page_offset ||= ((params[:page] || 1).to_i - 1) * per_page
  end

  def first_result_page?
    !params[:page] || params[:page].to_pagination_number == 1
  end

  def per_page
    (params[:per_page] || 20).to_pagination_number(20)
  end

  def ignore_search_event_flag_false?
    params[:ignore_search_event].nil? || params[:ignore_search_event].to_i.zero?
  end

  def store_search
    cookies[:last_search] = {
      value: params.except(:controller, :action).select { |_k, v| v.present? }.to_json,
      expires: 30.minutes.from_now
    }
  end

  def parse_uot_search_params
    @transactable_type = InstanceProfileType.buyer.first
  end

  def parse_community_search_params
    params[:search_type] = 'projects' unless %w(people projects topics groups).include?(params[:search_type])
    @search_type = params[:search_type]
    @transactable_type = InstanceProfileType.default.first
  end
end

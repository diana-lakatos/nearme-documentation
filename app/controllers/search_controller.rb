require 'will_paginate/array'
class SearchController < ApplicationController
  include SearchHelper
  include CoercionHelpers::Controller

  before_action :redirect_to_people_search
  before_action :coerce_pagination_params
  before_action :assign_transactable_type_id_to_lookup_context
  before_action :store_search

  before_action :parse_community_search_params, if:
    -> { PlatformContext.current.instance.is_community? }

  helper_method :searcher, :result_view, :current_page_offset, :per_page, :first_result_page?

  rescue_from ActiveRecord::RecordNotFound do
    redirect_back_or_default
  end

  def index
    @searcher = InstanceType::SearcherFactory.create(params, current_user)

    remember_search_query

    render "search/#{@searcher.result_view}", formats: [:html]
  end

  def categories
    category_ids = params[:category_ids].to_s.split(',').map(&:to_i)
    category_root_ids = Category.roots.map(&:id)
    @categories = Category.where(id: category_ids).order('lft ASC, id ASC').to_a
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
    @current_page_offset ||= (params[:page] - 1) * per_page
  end

  def first_result_page?
    params[:page] == 1
  end

  def per_page
    params[:per_page]
  end

  def ignore_search_event_flag_false?
    params[:ignore_search_event].nil? || params[:ignore_search_event].to_i.zero?
  end

  def store_search
    values = params.except(:controller, :action).select { |_k, v| v.present? }
    values[:transactable_type_class] ||= @transactable_type.class.name if @transactable_type
    cookies[:last_search] = {
      value: values.to_json,
      expires: 30.minutes.from_now
    }
  end

  def parse_community_search_params
    params[:search_type] = 'projects' unless %w(people projects topics groups).include?(params[:search_type])
    @search_type = params[:search_type]
    @transactable_type = InstanceProfileType.default.first
  end

  # TODO: temporary - discuss better approach and remove
  # in case of shitty transactable_type_class=InstanceProfileType redirect to nice search/people
  def redirect_to_people_search
    return unless params[:transactable_type_class] == 'InstanceProfileType'

    params.delete(:transactable_type_class)
    redirect_to search_path(params.merge(search_type: 'people'))
  end
end

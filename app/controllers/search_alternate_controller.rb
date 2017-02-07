# This search controller is intended to use graph query to make search
class SearchAlternateController < ApplicationController
  include SearchHelper
  include SearcherHelper
  include CoercionHelpers::Controller

  before_action :ensure_valid_params
  before_action :coerce_pagination_params
  before_action :find_transactable_type
  before_action :assign_transactable_type_id_to_lookup_context
  before_action :store_search

  before_action :parse_community_search_params, if:
    -> { PlatformContext.current.instance.is_community? }

  helper_method :searcher, :result_view, :current_page_offset, :per_page, :first_result_page?

  def index
    @transactable_type = @transactable_type.decorate

    render "search/#{result_view}", formats: [:html], locals: {
      g: execute_query(
        "search",
        { "transactable_type_id" => @transactable_type.id, "result_view" => result_view, "search_params" => search_params }
      )
    }
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

  def prepare_search_params
    permitted_keys = [
      :loc, :lat, :lng, :nx, :ny, :sx, :sy,
      :country, :state, :city, :postcode, :suburb, :street,
      :page, :per_page, :sort,
      :transactable_type_id, :transactable_id, :transactable_type_class,
      :language,
      :search_type
    ]
    params.permit(permitted_keys)
          .merge(per_page: per_page)
          .reverse_merge(sort: @transactable_type.default_sort_by)

  end

  def search_params
    @search_params ||= prepare_search_params
  end


  def execute_query(query_name, variables)
    response = ::Graph::Schema.execute(
      Graph::QueryResolver.find_query(query_name),
      variables: variables,
      context: {
        current_user: current_user,
        liquid_context: Liquid::Context.new({}, {}, {action_view: self })
      }
    )
    throw(ArgumentError.new(response.pretty_inspect)) if (!response.key?('data') || response.key?('errors'))

    data = response.fetch('data')
    Hashie::Mash.new(data)
  end
end

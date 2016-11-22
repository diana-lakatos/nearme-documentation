# frozen_string_literal: true
module InstanceType::Searcher
  attr_reader :results

  # @return [Integer] total number of results returned
  def result_count
    @search_results_count || @results.try(:total_entries) || @results.size
  end

  # @return [String, nil] query string or nil
  def query
    @query ||= search.query
  end

  # @param input_name [String] name for the input
  # @return [String] value for the input with the given name
  def input_value(input_name)
    @params[input_name]
  end

  # @return [Array<String,Integer>] array of searched for category ids
  def category_ids
    return input_value(:category_ids) if input_value(:category_ids).is_a?(Array)
    input_value(:category_ids).try { |ids| ids.split(',') } || []
  end

  # @return [Array<Category>] array of searched for categories
  def categories
    @categories ||= Category.where(id: category_ids) if input_value(:category_ids)
  end

  # @return [Array<Array<(Integer, String)>>] array of the form [[category_id, category_name_taken_from_translations], ...]
  def category_options(category)
    category.children.inject([]) { |options, c| options << [c.id, c.translated_name] }
  end

  def to_event_params
    { search_query: query, result_count: result_count }.merge(filters)
  end

  # @return [String, nil] query keyword
  def keyword
    @keyword ||= search.keyword
  end

  # @return [Boolean] whether search is geolocated
  def located
    (@transactable_type.searcher_type =~ /geo/ && search.midpoint.present?) || search.bounding_box.present?
  end

  def adjust_to_map
    @params[:map_moved] == 'true'
  end

  def global_map
    !@params[:loc].present?
  end

  def repeated_search?(values)
    (@params[:loc] || @params[:query]) && search_query_values.to_s == values.try(:to_s)
  end

  # @return [Integer] search offset (with what result number we're starting)
  def offset
    @offset || @results.offset
  end

  # @return [Integer] minimum price requested for the search
  def min_price
    @params[:price] ? @params[:price][:min].to_i : 0
  end

  def count_query(query)
    query.count('*', distinct: true)
  end

  def postgres_filters?
    true
  end

  def searchable_categories
    @transactable_type.categories.searchable.roots.includes(children: [:children])
  end

  # @return [Boolean] whether a minimum price was requested for the query
  def current_min_price
    @params[:price] && @params[:price][:min]
  end

  # @return [Boolean] whether a maximum price was requested for the query
  def current_max_price
    @params[:price] && @params[:price][:max]
  end

  def paginate_results(page = 1, per_page)
    paginated_results(page || 1, per_page)
  end

  def paginated_results(page, per_page)
    @results = @results.paginate(page: page.to_pagination_number, per_page: per_page.to_pagination_number(20), total_entries: @search_results_count)
  end

  def total_pages
    result_count / @params[:per_page].to_pagination_number(20)
  end

  # @return [TransactableTypeDecorator] transactable type object associated with the query
  def transactable_type
    @transactable_type_decorator ||= @transactable_type.decorate
  end

  def to_liquid
    @searcher_drop ||= SearcherDrop.new(self)
  end

  def service_radius_enabled?
    @transactable_type.custom_attributes.exists?(name: :service_radius)
  end

  def filterable_pricing
    @filterable_pricing ||= transactable_type.action_types.flat_map do |at|
      at.pricings.map do |pricing|
        [pricing.units_to_s, pricing.units_translation('reservations.per_unit_price').downcase.titleize]
      end
    end
    if transactable_type.action_types.any?(&:allow_free_booking?)
      @filterable_pricing << ['0_free', I18n.t('search.pricing_types.free')]
    end
    @filterable_pricing.sort.uniq
  end
end

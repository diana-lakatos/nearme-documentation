module InstanceType::Searcher

  attr_reader :results

  def result_count
    @search_results_count || @results.try(:total_entries) || @results.size
  end

  def query
    @query ||= search.query
  end

  def input_value(input_name)
    @params[input_name]
  end

  def category_ids
    input_value(:category_ids).try { |ids| ids.split(',') } || []
  end

  def categories
    @categories ||= Category.where(id: category_ids) if input_value(:category_ids)
  end

  def category_options(category)
    category.children.inject([]) { |options, c| options << [c.id, c.translated_name] }
  end

  def should_log_conducted_search?
    @params[:loc].present? || @params[:query].present?
  end

  def to_event_params
    { search_query: query, result_count: result_count }.merge(filters)
  end

  def keyword
    @keyword ||= search.keyword
  end

  def located
    @params[:lat].present? and @params[:lng].present?
  end

  def adjust_to_map
    @params[:loc].present? || @params[:nx].present? && @params[:sx].present?
  end

  def global_map
    !@params[:loc].present?
  end

  def repeated_search?(values)
    (@params[:loc] || @params[:query]) && search_query_values.to_s == values.try(:to_s)
  end

  def offset
    @offset || @results.offset
  end

  def min_price
    @params[:price] ? @params[:price][:min].to_i : 0
  end

  def count_query(query)
    query.count("*", distinct: true)
  end

  def postgres_filters?
    true
  end

  def searchable_categories
    @transactable_type.categories.searchable.roots.includes(children: [:children])
  end

  def current_min_price
    @params[:price] && @params[:price][:min]
  end

  def current_max_price
    @params[:price] && @params[:price][:max]
  end

  def paginate_results(page = 1, per_page)
    paginated_results(page || 1, per_page)
  end

  def paginated_results(page, per_page)
    @results = @results.paginate(page: sanitize_pagination_number(page), per_page: sanitize_pagination_number(per_page, 20), total_entries: @search_results_count)
  end

  # We do this to prevent will_paginate from throwing errors because of invalid page numbers, per_page etc.
  def sanitize_pagination_number(number, default = 1)
    number = number.to_i
    number = default if number.zero?
    number
  end

  def transactable_type
    @transactable_type_decorator ||= @transactable_type.decorate
  end

end

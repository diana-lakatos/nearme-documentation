class InstanceType::Searcher::Elastic::ProductsSearcher
  include InstanceType::Searcher

  attr_reader :search, :filterable_custom_attributes

  def initialize(product_type, params)
    @product_type = product_type
    set_options_for_filters
    @params = params
    @results = fetcher
  end

  def filters
    search_filters = {}
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

  def to_event_params
    { search_query: query, result_count: result_count }.merge(filters)
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

  def query
    @query ||= search.query
  end

  def taxon
    @taxon ||= Spree::Taxon.find_by!(permalink: search.taxon) unless search.taxon.blank?
  end

  def search
    @search ||= Spree::Product::Search::Params::Web.new(@params)
  end

  def fetcher
    @fetcher ||=
      begin
        @search_params = @params.merge({
          query: search.query,
          name: search.query,
          description: search.query,
          custom_attributes: search.lg_custom_attributes,
          category_ids: category_ids,
          sort: search.sort
        })
        product_searcher = initialize_searcher_params
        
        Spree::Product.search(product_searcher.merge(@search_params).merge(limit: 100)).records
      end
  end

  def repeated_search?(values)
    @params[:query] && search_query_values.to_s == values.try(:to_s)
  end

  def set_options_for_filters
    @filterable_custom_attributes = @product_type.custom_attributes.searchable
  end

  def search_query_values
    {
      query: @params[:query]
    }.merge(filters)
  end

  def should_log_conducted_search?
    @params[:query].present?
  end

  def searchable_categories
    @product_type.categories.searchable.roots
  end

  def min_price
    @params[:price] ? @params[:price][:min].to_i : 0
  end

  private

  def initialize_searcher_params
    {instance_id: PlatformContext.current.instance.id}
  end

end
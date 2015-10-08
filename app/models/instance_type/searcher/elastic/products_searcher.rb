class InstanceType::Searcher::Elastic::ProductsSearcher
  include InstanceType::Searcher

  attr_reader :filterable_custom_attributes, :search

  def initialize(product_type, params)
    @product_type = product_type
    @transactable_type = @product_type
    set_options_for_filters
    @params = params
    @results = fetcher
  end

  def filters
    search_filters = {}
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
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
        @fetched = Spree::Product.search(product_searcher.merge(@search_params), @product_type)
        @search_results_count = @fetched.response[:hits][:total]

        Spree::Product.where(id: @fetched.map(&:id)).includes(:company, master: [:default_price])
      end
  end

  def search
    @search ||= Spree::Product::Search::Params::Web.new(@params)
  end

  def paginated_results(page, per_page)
    @results = @results.paginate(page: page, per_page: per_page, total_entries: @search_results_count).offset(0)
  end

  def set_options_for_filters
    @filterable_custom_attributes = @product_type.custom_attributes.searchable
  end

  def search_query_values
    {
      query: @params[:query]
    }.merge(filters)
  end

  def min_price
    @fetched.response[:aggregations]["filtered_price_range"]["min_price"]["value"]
  end

  def max_price
    @fetched.response[:aggregations]["filtered_price_range"]["max_price"]["value"]
  end

  private

  def initialize_searcher_params
    {instance_id: PlatformContext.current.instance.id, product_type_id: @product_type.try(:id)}
  end

end
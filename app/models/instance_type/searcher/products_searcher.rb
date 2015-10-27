class InstanceType::Searcher::ProductsSearcher
  include InstanceType::Searcher

  attr_reader :filterable_custom_attributes, :search

  def initialize(product_type, params)
    @product_type = product_type
    @transactable_type = @product_type
    set_options_for_filters
    @params = params
    @results = fetcher.products
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
          custom_attributes: search.lg_custom_attributes,
          category_ids: search.category_ids,
          sort: search.sort
        })
        Spree::Product::SearchFetcher.new(@search_params, @transactable_type)
      end
  end

  def search
    @search ||= Spree::Product::Search::Params::Web.new(@params)
  end

  def set_options_for_filters
    @filterable_custom_attributes = @product_type.custom_attributes.searchable
  end

  def search_query_values
    {
      query: @params[:query]
    }.merge(filters)
  end

  def prices
    @prices ||= @results.map(&:price)
  end

  def min_price
    return 0 if !@transactable_type.show_price_slider || results.blank?
    @min_fixed_price ||= prices.min
  end

  def max_price
    return 0 if !@transactable_type.show_price_slider || results.blank?
    @max_fixed_price ||= prices.max
  end

end

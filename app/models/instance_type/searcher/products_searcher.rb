class InstanceType::Searcher::ProductsSearcher
  include InstanceType::Searcher

  attr_reader :filterable_attribute, :search

  def initialize(product_type, params)
    @product_type = product_type
    set_options_for_filters
    @params = params
    @results = fetcher.products
  end

  def filters
    search_filters = {}
    search_filters[:attribute_filter] = @params[:attribute_values]
    search_filters
  end

  def to_event_params
    { search_query: query, result_count: result_count }.merge(filters)
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
          taxon: search.taxon,
          attribute_values: search.attribute_values_filters,
          sort: search.sort
        })

        Spree::Product::SearchFetcher.new(@search_params)
      end
  end

  def repeated_search?(values)
    @params[:loc] && search_query_values.to_s == values.try(:to_s)
  end

  def set_options_for_filters
    @filterable_attribute = @product_type.custom_attributes.where(name: 'filterable_attribute').try(:first).try(:valid_values)
  end

  def search_query_values
    {
      loc: @params[:loc]
    }.merge(filters)
  end

  def should_log_conducted_search?
    @params[:loc].present?
  end

end

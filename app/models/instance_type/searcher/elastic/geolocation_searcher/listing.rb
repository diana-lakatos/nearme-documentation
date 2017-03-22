class InstanceType::Searcher::Elastic::GeolocationSearcher::Listing < Searching::ElasticSearchBased
  def initialize(transactable_type, params)
    super(transactable_type, params)
    @filters = { date_range: [] }
  end

  def invoke
    set_options_for_filters
    @filters = { date_range: search.available_dates }

    listing_ids = fetcher.map(&:id)

    listings_scope = ::Transactable.all

    if postgres_filters?
      listings_scope = available_listings(listings_scope)
      order_ids = listing_ids[@offset..(@to + 5)]
      order_ids = listing_ids if order_ids.blank?
    else
      @search_results_count = fetcher.results.total
      order_ids = listing_ids
    end

    listings_scope = listings_scope.where(id: listing_ids)

    @results = listings_scope
                 .includes(:location, :location_address, :company, :photos, :transactable_type, :action_type, creator: [:user_profiles])
                 .order_by_array_of_ids(order_ids)
                 .paginate(page: params[:page], per_page: params[:per_page], total_entries: @search_results_count)
    @results = @results.offset(0) unless postgres_filters?
  end

  def search_params
    @search_params ||= params.merge date_range: search.available_dates,
                                    custom_attributes: search.lg_custom_attributes,
                                    location_types_ids: search.location_types_ids,
                                    listing_pricing: search.lgpricing.blank? ? [] : search.lgpricing_filters,
                                    category_ids: category_ids,
                                    sort: search.sort
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = params[:location_types_ids] if params[:location_types_ids]
    search_filters[:custom_attributes] = params[:lg_custom_attributes] unless params[:lg_custom_attributes].blank?
    search_filters
  end

  def max_price
    return 0 if !@transactable_type.show_price_slider || results.blank?
    max = fetcher.response[:aggregations]['filtered_aggregations']['maximum_price'].try(:[], 'value') || 0
    max / 100
  end

  private

  def default_search_params
    { instance_id: PlatformContext.current.instance.id, transactable_type_id: @transactable_type.id }
  end
end

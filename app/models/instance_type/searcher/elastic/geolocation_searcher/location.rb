class InstanceType::Searcher::Elastic::GeolocationSearcher::Location
  include InstanceType::Searcher::Elastic::GeolocationSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    @params = params
    @filters = {date_range: search.available_dates}
    transactable_ids = []
    location_ids = []

    fetcher.to_a.each{|f| 
      location_ids << f['_source']['location_id'].to_i
      transactable_ids << f['_id'].to_i 
    }
    location_ids.uniq!

    listings_scope = Transactable.where(id: transactable_ids)
    listings_scope = available_listings(listings_scope)
    filtered_listings = Transactable.where(id: listings_scope.pluck(:id))

    scoped_transactables_compacted = ::Location.includes(:listings).where(id: location_ids).order_by_array_of_ids(location_ids).merge(filtered_listings).all
    @search_results_count = filtered_listings.count
    @results = scoped_transactables_compacted
  end
  
  def filters
    search_filters = {}
    search_filters[:location_type_filter] = search.location_types_ids.map { |lt| lt.respond_to?(:name) ? lt.name : lt } if search.location_types_ids && !search.location_types_ids.empty?
    search_filters[:listing_pricing_filter] = search.lgpricing_filters if not search.lgpricing_filters.empty?
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

  private

  def initialize_search_params
    { instance_id: PlatformContext.current.instance.id, transactable_type_id: @transactable_type.id }
  end

end
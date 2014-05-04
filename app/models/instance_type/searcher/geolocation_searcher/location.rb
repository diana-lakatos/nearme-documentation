class InstanceType::Searcher::GeolocationSearcher::Location
  include InstanceType::Searcher::GeolocationSearcher

  def initialize(params)
    set_options_for_filters
    @params = params
    @results = fetcher.locations
  end

  def filters
    search_filters = {}
    search_filters[:listing_type_filter] = search.listing_types_ids if search.listing_types_ids && !search.listing_types_ids.empty?
    search_filters[:location_type_filter] = search.location_types_ids.map(&:name) if search.location_types_ids && !search.location_types_ids.empty?
    search_filters[:listing_pricing_filter] = search.lgpricing_filters if not search.lgpricing_filters.empty?
    search_filters
  end

end

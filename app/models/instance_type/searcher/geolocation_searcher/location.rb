class InstanceType::Searcher::GeolocationSearcher::Location
  include InstanceType::Searcher::GeolocationSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    @params = params
    scoped_transactables  = fetcher.locations
    if params['query'].present?
      query = params['query'].split(' ').join(' & ') + ":*"
      scoped_transactables = scoped_transactables.where("CAST(avals(properties) AS text) @@ to_tsquery(:q)", q: query)
    end
    @results = scoped_transactables
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = search.location_types_ids.map { |lt| lt.respond_to?(:name) ? lt.name : lt } if search.location_types_ids && !search.location_types_ids.empty?
    search_filters[:listing_pricing_filter] = search.lgpricing_filters if not search.lgpricing_filters.empty?
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

end

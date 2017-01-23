class InstanceType::Searcher::GeolocationSearcher::Listing < Searching::SqlBased
  def initialize(transactable_type, params)
    super(transactable_type, params)
    set_options_for_filters
  end

  def invoke
    @results = fetcher.listings
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = search.location_types_ids if search.location_types_ids && !search.location_types_ids.empty?
    search_filters[:custom_attributes] = params[:lg_custom_attributes] unless params[:lg_custom_attributes].blank?
    search_filters
  end

  def max_price
    return 0 if !@transactable_type.show_price_slider || @results.blank?
    @max_fixed_price ||= (@results.map(&:action_type).compact.map(&:pricings).flatten.compact.map(&:price_cents).compact.max || 0).to_f / 100
    @max_fixed_price > 0 ? @max_fixed_price + 1 : @max_fixed_price
  end
end

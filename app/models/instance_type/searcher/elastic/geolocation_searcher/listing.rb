class InstanceType::Searcher::Elastic::GeolocationSearcher::Listing
  include InstanceType::Searcher::Elastic::GeolocationSearcher

  def initialize(transactable_type, params)
    @transactable_type = transactable_type
    set_options_for_filters
    @params = params
    @filters = {date_range: search.available_dates}

    listing_ids = fetcher.to_a.map{|f| f['_id'].to_i}
    listings_scope = ::Transactable.where(id: listing_ids)
    listings_scope = available_listings(listings_scope)

    filtered_listings = ::Transactable.includes(:location).where(id: listings_scope.pluck(:id)).order_by_array_of_ids(listing_ids)

    scoped_transactables_compacted = filtered_listings.all
    @search_results_count = filtered_listings.count
    @results = scoped_transactables_compacted
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = @params[:location_types_ids].map { |lt| LocationType.find(lt).name } if @params[:location_types_ids]
    search_filters[:industry_filter] = @params[:industries_ids].map { |i| Industry.find(i).name } if @params[:industries_ids]
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

  private

  def initialize_search_params
    { instance_id: PlatformContext.current.instance.id, transactable_type_id: @transactable_type.id }
  end

end
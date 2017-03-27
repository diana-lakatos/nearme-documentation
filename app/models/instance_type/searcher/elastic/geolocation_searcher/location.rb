# frozen_string_literal: true
class InstanceType::Searcher::Elastic::GeolocationSearcher::Location < Searching::ElasticSearchBased
  LOAD_ALL_ITEMS = 10_000

  def initialize(transactable_type, params)
    super(transactable_type, params)
    set_options_for_filters
    @filters = { date_range: search_form.available_dates }
    locations = {}

    fetcher.each do |f|
      locations[f.fields.location_id.first] ||= []
      locations[f.fields.location_id.first] << f.id
    end

    location_ids = locations.keys

    if postgres_filters?
      listings_scope = Transactable.where(id: locations.values.flatten)
      listings_scope = available_listings(listings_scope)

      order_ids = locations.keys[@offset..@to]
      filtered_listings = Transactable.where(id: listings_scope.pluck(:id))
    else
      locations = locations.to_a[@offset..@to].to_h

      order_ids = location_ids
      filtered_listings = Transactable.where(id: locations.values.flatten)
    end

    @search_results_count = fetcher.response[:aggregations]['filtered_aggregations']['distinct_locations'][:value]
    @results = ::Location
               .includes(:location_address, :company, listings: [:transactable_type])
               .where(id: location_ids).order_by_array_of_ids(order_ids).merge(filtered_listings)
               .paginate(page: @params[:page], per_page: @params[:per_page], total_entries: @search_results_count)
    @results = @results.offset(0) unless postgres_filters?
  end

  def search_params
    @search_params ||= params.merge date_range: search_form.available_dates,
                                    custom_attributes: search_form.lg_custom_attributes,
                                    location_types_ids: search_form.location_types_ids,
                                    listing_pricing: search_form.lgpricing.blank? ? [] : search_form.lgpricing_filters,
                                    category_ids: category_ids,
                                    sort: search_form.sort,
                                    page: 1,
                                    limit: LOAD_ALL_ITEMS
  end

  def max_price
    return 0 if !@transactable_type.show_price_slider || results.blank?
    max = fetcher.response[:aggregations]['filtered_aggregations']['maximum_price'].try(:[], 'value') || 0
    max / 100
  end

  def filters
    search_filters = {}
    search_filters[:location_type_filter] = search_form.location_types_ids if search_form.location_types_ids && !search_form.location_types_ids.empty?
    search_filters[:listing_pricing_filter] = search_form.lgpricing_filters unless search_form.lgpricing_filters.empty?
    search_filters[:custom_attributes] = @params[:lg_custom_attributes] unless @params[:lg_custom_attributes].blank?
    search_filters
  end

  private

  def default_search_params
    { instance_id: PlatformContext.current.instance.id, transactable_type_id: @transactable_type.id }
  end
end

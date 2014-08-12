module InstanceType::Searcher::GeolocationSearcher
  include InstanceType::Searcher
  attr_reader :filterable_location_types, :filterable_listing_types, :filterable_pricing, :filterable_attribute, :search

  def to_event_params
    { search_query: query, result_count: result_count }.merge(filters)
  end

  def query
    @query ||= search.query
  end

  def located
    @params[:lat].present? and @params[:lng].present?
  end

  def search
    @search ||= ::Listing::Search::Params::Web.new(@params)
  end

  def fetcher
    @fetcher ||=
      begin
        @search_params = @params.merge({
          :midpoint => search.midpoint,
          :radius => search.radius,
          :available_dates => search.available_dates,
          :query => search.query,
          :location_types_ids => search.location_types_ids,
          :listing_types_ids => search.listing_types_ids,
          :attribute_values => search.attribute_values_filters,
          :listing_pricing => search.lgpricing.blank? ? [] : search.lgpricing_filters,
          :sort => search.sort
        })

        ::Listing::SearchFetcher.new(@search_params)
      end
  end

  def search_query_values
    {
      :loc => @params[:loc],
      :industries_ids => @params[:industries_ids],
    }.merge(filters)
  end

  def repeated_search?(values)
    @params[:loc] && search_query_values.to_s == values.try(:to_s)
  end

  def set_options_for_filters
    @filterable_location_types = LocationType.all
    @filterable_listing_types = TransactableType.first.transactable_type_attributes.where(:name => 'listing_type').try(:first).try(:valid_values)
    @filterable_pricing = TransactableType.first.pricing_options.keys.map { |k| [k.downcase, k.capitalize] }
    @filterable_attribute = TransactableType.first.transactable_type_attributes.where(:name => 'filterable_attribute').try(:first).try(:valid_values)
  end

  def search_notification
    @search_notification ||= SearchNotification.new(query: @params[:loc], latitude: @params[:lat], longitude: @params[:lng])
  end

  def search_query_values
    {
      :loc => @params[:loc],
      :industries_ids => @params[:industries_ids],
    }.merge(filters)
  end

  def repeated_search?(values)
    @params[:loc] && search_query_values.to_s == values.try(:to_s)
  end

  def should_log_conducted_search?
    @params[:loc].present?
  end
end

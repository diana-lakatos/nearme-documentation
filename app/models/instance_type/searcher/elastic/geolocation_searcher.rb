module InstanceType::Searcher::Elastic::GeolocationSearcher
  include InstanceType::Searcher
  attr_reader :filterable_location_types, :filterable_custom_attributes, :search

  def fetcher
    @fetcher ||=
      begin
        @search_params = @params.merge(date_range: search.available_dates,
                                       custom_attributes: search.lg_custom_attributes,
                                       location_types_ids: search.location_types_ids,
                                       listing_pricing: search.lgpricing.blank? ? [] : search.lgpricing_filters,
                                       category_ids: category_ids,
                                       sort: search.sort,
                                       limit: per_page_elastic,
                                       page: page_elastic)

        geo_searcher_params = initialize_search_params

        if located || adjust_to_map
          extend_params_by_geo_filters
          Transactable.geo_search(geo_searcher_params.merge(@search_params), @transactable_type)
        else
          Transactable.regular_search(geo_searcher_params.merge(@search_params), @transactable_type)
        end

      end
  end

  def search
    @search ||= ::Listing::Search::Params::Web.new(@params, @transactable_type)
  end

  def search_query_values
    {
      loc: @params[:loc],
      query: @params[:query]
    }.merge(filters)
  end

  def set_options_for_filters
    @filterable_location_types = LocationType.all
    @filterable_custom_attributes = @transactable_type.custom_attributes.searchable.where(" NOT (custom_attributes.attribute_type = 'string' AND custom_attributes.html_tag IN ('input', 'textarea'))")
    per_page = [@params[:per_page].to_i, 20].max
    @offset = [((@params[:page].to_pagination_number - 1) * per_page), 0].max
    @to = @offset + per_page + 5
  end

  def search_notification
    @search_notification ||= SearchNotification.new(query: @params[:loc], latitude: @params[:lat], longitude: @params[:lng])
  end

  def date_range_to_days
    @filters[:date_range].inject([]) do |days, date|
      # we need only weekdays, so no point in iterating further
      return days if days.count == 7
      days << date.wday
    end.sort
  end

  def availability_filter?
    (@filters[:availability] && @filters[:availability][:dates] && @filters[:availability][:dates][:start].present? && @filters[:availability][:dates][:end].present?) || @filters[:date_range].first && @filters[:date_range].last
  end

  def relative_availability?
    @transactable_type.date_pickers_relative_mode?
  end

  def available_listings(listings_scope)
    if availability_filter?
      if relative_availability?
        listings_scope = listings_scope.not_booked_relative(@filters[:date_range].first, @filters[:date_range].last)
      else
        listings_scope = listings_scope.not_booked_absolute(@filters[:date_range].first, @filters[:date_range].last)
      end
    end
    listings_scope
  end

  def postgres_filters?
    availability_filter?
  end

  def paginated_results(page, per_page)
    @results = @results.paginate(page: page.to_pagination_number, per_page: per_page.to_pagination_number(20), total_entries: @search_results_count)
    @results = @results.offset(0) unless postgres_filters?
  end

  def extend_params_by_geo_filters
    if adjust_to_map || (!search.precise_address? && !service_radius_enabled? && search.bounding_box)
      @search_params.merge!(bounding_box: search.bounding_box)
    end

    if located
      lat, lng = search.midpoint
      radius = @transactable_type.search_radius.to_i
      radius = search.radius.to_i if radius.zero?

      @search_params.merge!(lat: lat,
                            lon: lng,
                            distance: "#{radius}km")
    end
  end

  def per_page_elastic
    postgres_filters? ? nil : @params[:per_page]
  end

  def page_elastic
    postgres_filters? ? nil : @params[:page]
  end
end

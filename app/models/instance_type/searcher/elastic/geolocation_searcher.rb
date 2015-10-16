module InstanceType::Searcher::Elastic::GeolocationSearcher
  include InstanceType::Searcher
  attr_reader :filterable_location_types, :filterable_custom_attributes, :filterable_pricing, :search

  SEARCHER_DEFAULT_PRICING_TYPES = %w(daily weekly monthly hourly free)

  def per_page_elastic
    postgres_filters? ? nil : @params[:per_page]
  end

  def page_elastic
    postgres_filters? ? nil : @params[:page]
  end

  def fetcher
    @fetcher ||=
      begin
        @search_params = @params.merge({
          date_range: search.available_dates,
          custom_attributes: search.lg_custom_attributes,
          location_types_ids: search.location_types_ids,
          listing_pricing: search.lgpricing.blank? ? [] : search.lgpricing_filters,
          category_ids: category_ids,
          sort: search.sort,
          limit: per_page_elastic,
          page: page_elastic
        })

        geo_searcher_params = initialize_search_params
        if located || adjust_to_map
          radius = PlatformContext.current.instance.search_radius.to_i
          radius = search.radius.to_i if radius.zero?
          lat, lng = search.midpoint.nil? ? [0.0, 0.0] : search.midpoint.map(&:to_s)
          if !search.country.blank? && search.city.blank? || global_map
            @search_params.merge!({
              bounding_box: search.bounding_box
            })
          end
          Transactable.geo_search(geo_searcher_params.merge(@search_params).merge({distance: "#{radius}km", lat: lat, lon: lng}), @transactable_type)
        else
          Transactable.regular_search(geo_searcher_params.merge(@search_params))
        end
      end
  end

  def search
    @search ||= ::Listing::Search::Params::Web.new(@params)
  end

  def search_query_values
    {
      :loc => @params[:loc],
      :query => @params[:query],
      :industries_ids => @params[:industries_ids]
    }.merge(filters)
  end

  def set_options_for_filters
    @filterable_location_types = LocationType.all
    @filterable_pricing = SEARCHER_DEFAULT_PRICING_TYPES.map{|price| [price, I18n.t("search.pricing_types.#{price}")] if @transactable_type.send("action_#{price}_booking")}.compact
    @filterable_pricing += [['weekly_subscription', I18n.t("search.pricing_types.weekly")], ['monthly_subscription', I18n.t("search.pricing_types.monthly")]] if @transactable_type.action_subscription_booking
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
    @filters[:availability] && @filters[:availability][:dates] && @filters[:availability][:dates][:start].present? && @filters[:availability][:dates][:end].present? && @filters[:date_range].first && @filters[:date_range].last
  end

  def relative_availability?
    @relative ||= PlatformContext.current.instance.date_pickers_relative_mode?
  end

  def available_listings(listings_scope)
    if availability_filter?
      if relative_availability?
        listings_scope = listings_scope.not_booked_relative(@filters[:date_range].first, @filters[:date_range].last)
        listings_scope = listings_scope.only_opened_on_at_least_one_of(date_range_to_days)
      else
        listings_scope = listings_scope.not_booked_absolute(@filters[:date_range].first, @filters[:date_range].last)
        listings_scope = listings_scope.only_opened_on_all_of(date_range_to_days)
      end
      listings_scope = listings_scope.overlaps_schedule_start_date(@filters[:date_range].first)
    end
    listings_scope
  end

  def postgres_filters?
    availability_filter? || price_filter?
  end

  def price_filter?
    @params[:price] && !@params[:price][:max].to_i.zero?
  end

  def price_filter(listings_scope)
    if price_filter?
      listings_scope = listings_scope.where('transactables.fixed_price_cents >= ? AND transactables.fixed_price_cents <= ?', @params[:price][:min].to_i * 100, @params[:price][:max].to_i * 100)
    end
    listings_scope
  end

  def paginated_results(page, per_page)
    @results = @results.paginate(page: page.to_pagination_number, per_page: per_page.to_pagination_number(20), total_entries: @search_results_count)
    @results = @results.offset(0) unless postgres_filters?
  end

end

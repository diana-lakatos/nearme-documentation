module InstanceType::Searcher::Elastic::GeolocationSearcher
  include InstanceType::Searcher
  attr_reader :filterable_location_types, :filterable_custom_attributes, :filterable_pricing, :search

  SEARCHER_DEFAULT_PRICING_TYPES = %w(daily weekly monthly hourly)

  def to_event_params
    { search_query: query, result_count: result_count }.merge(filters)
  end

  def query
    @query ||= search.query
  end

  def keyword
    @keyword ||= search.keyword
  end

  def located
    @params[:lat].present? and @params[:lng].present?
  end

  def input_value(input_name)
    @params[input_name]
  end

  def adjust_to_map
    @params[:loc].present? || @params[:nx].present? && @params[:sx].present?
  end

  def search
    @search ||= ::Listing::Search::Params::Web.new(@params)
  end

  def category_ids
    input_value(:category_ids).try { |ids| ids.split(',') } || []
  end

  def categories
    @categories ||= Category.where(id: category_ids) if input_value(:category_ids)
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
          sort: search.sort
        })
        
        geo_searcher_params = initialize_search_params
        
        if located || adjust_to_map
          radius = PlatformContext.current.instance.search_radius.to_i
          radius = search.radius.to_i if radius.zero?
          Transactable.geo_search(geo_searcher_params.merge(@search_params).merge({distance: "#{radius}km", lat: search.midpoint.first.to_s, lon: search.midpoint.last.to_s}))
        else
          Transactable.regular_search(geo_searcher_params.merge(@search_params))
        end
      end
  end

  def search_query_values
    {
      :loc => @params[:loc],
      :query => @params[:query],
      :industries_ids => @params[:industries_ids],
    }.merge(filters)
  end

  def repeated_search?(values)
    (@params[:loc] || @params[:query]) && search_query_values.to_s == values.try(:to_s)
  end

  def set_options_for_filters
    @filterable_location_types = LocationType.all
    @filterable_pricing = SEARCHER_DEFAULT_PRICING_TYPES.map{|price| [price, price.capitalize] if @transactable_type.send("action_#{price}_booking")}.compact
    @filterable_custom_attributes = @transactable_type.custom_attributes.searchable.all.select{|a| !(a.attribute_type == 'string' && (a.html_tag == 'input' || a.html_tag == 'textarea'))}
  end

  def search_notification
    @search_notification ||= SearchNotification.new(query: @params[:loc], latitude: @params[:lat], longitude: @params[:lng])
  end

  def should_log_conducted_search?
    @params[:loc].present? || @params[:query].present?
  end

  def searchable_categories
    @transactable_type.categories.searchable.roots
  end

  def category_options(category)
    category.children.inject([]) { |options, c| options << [c.id, c.translated_name] }
  end

end

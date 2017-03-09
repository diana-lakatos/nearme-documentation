module InstanceType::Searcher::GeolocationSearcher
  include InstanceType::Searcher
  attr_reader :filterable_location_types, :filterable_custom_attributes, :search

  def fetcher
    @fetcher ||=
      begin
        @search_params = @params.merge(date_range: search.available_dates,
                                       transactable_type_id: @transactable_type.id,
                                       custom_attributes: search.lg_custom_attributes,
                                       category_ids: search.category_ids,
                                       location_types_ids: search.location_types_ids,
                                       listing_pricing: search.lgpricing.blank? ? [] : search.lgpricing_filters,
                                       sort: search.sort,
                                       query: search.keyword,
                                       loc: search.loc)
        radius = @transactable_type.search_radius.to_i
        radius = search.radius.to_i if radius.zero?

        if located || adjust_to_map
          @search_params.merge!(midpoint: search.midpoint,
                                radius: radius)
          if search.country.present? && search.city.blank? || global_map
            @search_params.merge!(bounding_box: search.bounding_box)
          end
        end

        ::Listing::SearchFetcher.new(@search_params, @transactable_type)
      end
  end

  def search
    @search ||= ::Listing::Search::Params::Web.new(@params, @transactable_type)
  end

  def search_form
    search
  end

  def search_query_values
    {
      loc: @params[:loc],
      query: @params[:query]
    }.merge(filters)
  end

  def set_options_for_filters
    @filterable_location_types = LocationType.all
    @filterable_custom_attributes = @transactable_type.custom_attributes.searchable
  end
end

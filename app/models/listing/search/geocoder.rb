class Listing::Search::Geocoder

  def self.find_search_area(query)
    geocoded = ::Geocoder.search(query).try(:first)
    return nil if geocoded.nil?

    geo = geocoded.data['geometry']
    center = [geo['location']['lat'], geo['location']['lng']]

    bounds = if b = geo['viewport'] || geo['bounds']
      [b['northeast'].values, b['southwest'].values]
    else
      radius = geo['location_type'] == 'ROOFTOP' ? Listing::Search::Params::MIN_SEARCH_RADIUS : Listing::Search::Params::DEFAULT_SEARCH_RADIUS
      box = ::Geocoder::Calculations.bounding_box([center.lat, center.long], radius)
      [box[0..1], box[2..3]]
    end

    radius ||= ::Geocoder::Calculations.distance_between(*bounds)

    return Listing::Search::Area.new(center, bounds, radius, address_components(geocoded))
  end

  def self.address_components(geocoded)
    address_components = geocoded.data['address_components']

    populator = Location::AddressComponentsPopulator.new
    populator.set_result(geocoded)
    wrapped_address_components = populator.wrap_result_address_components

    Location::GoogleGeolocationDataParser.new(wrapped_address_components)
  end

end

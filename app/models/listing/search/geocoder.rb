class Listing::Search::Geocoder
  def self.find_search_area(query)
    geocoded = ::Geocoder.search(query).try(:first)
    return nil if geocoded.nil?
    geo = geocoded.data['geometry']
    center = [geo['location']['lat'], geo['location']['lng']]

    bounds = if b = geo['viewport'] || geo['bounds']
                {
                  top_right: {
                    lat: b['northeast']['lat'],
                    lon: b['northeast']['lng']
                  },
                  bottom_left: {
                    lat: b['southwest']['lat'],
                    lon: b['southwest']['lng']
                  }
                }
             else
               radius = geo['location_type'] == 'ROOFTOP' ? Listing::Search::Params::MIN_SEARCH_RADIUS : Listing::Search::Params::DEFAULT_SEARCH_RADIUS
               box = ::Geocoder::Calculations.bounding_box([center.lat, center.long], radius)
               {
                  top_right: {
                    lat: box[0],
                    lon: box[1]
                  },
                  bottom_left: {
                    lat: box[2],
                    lon: box[3]
                  }
                }
    end

    radius ||= ::Geocoder::Calculations.distance_between(bounds[:top_right].values, bounds[:bottom_left].values)

    Listing::Search::Area.new(center, bounds, radius, address_components(geocoded))
  end

  def self.address_components(geocoded)
    wrapped_address_components = Address::AddressComponentsPopulator.wrapped_address_components(geocoded)
    Address::GoogleGeolocationDataParser.new(wrapped_address_components)
  end
end

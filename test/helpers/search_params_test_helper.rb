module SearchParamsTestHelper
  def fake_geocoder(finds_result)
    stub("Geocoder", find_location: finds_result, pretty: "City, State")
  end

  def options_with_bounding_box(options={})
    { boundingbox: { start: { lat: 10, lon:-10 } , end: { lat: 18, lon: 18 } } }.merge(options)
  end

  def options_with_midpoint(options={})
    { location: { lat: 37.0, lon: 128.0 } }.merge(options)
  end

  def search_area(midpoint=midpoint)
    Listing::Search::Area.new(midpoint, 5.0)
  end

  def midpoint
    Coordinate.new(37.0, 128.0)
  end

  def scope_for(options, geocoder)
    Listing::Search::Params::Api.new(options, geocoder).to_scope
  end

  def options_with_query(query='asdf')
    { query: query }
  end

  def query_midpoint
    Coordinate.new(1.0, 2.0)
  end

end

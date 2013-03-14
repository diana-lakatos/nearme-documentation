module SearchParamsTestHelper
  def fake_geocoder(finds_result = true)
    _search_area = !!finds_result ? search_area : false
    stub('Geocoder', find_search_area: _search_area)
  end

  def options_with_bounding_box(options={})
    { boundingbox: { start: { lat: 10, lon: -10 } , end: { lat: 18, lon: 18 } } }.deep_merge(options)
  end

  def options_with_location(options={})
    { location: { lat: 37.0, lon: 128.0 } }.deep_merge(options)
  end

  def search_area(_midpoint = nil, _radius = nil)
    Listing::Search::Area.new((_midpoint || midpoint), nil, (_radius || radius))
  end
  
  def radius
    10.0
  end
  
  def midpoint
    [37.0, 128.0]
  end
  
  def args_for(options, geocoder)
    Listing::Search::Params::Api.new(options, geocoder).to_args
  end

  def options_with_query(query='asdf')
    { query: query }
  end

  def query_midpoint
    [1.0, 2.0]
  end

end
